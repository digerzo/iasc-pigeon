defmodule ChatGroups do
  use GenServer
  require Logger

  @chat_group_registry_name ChatGroups.Registry

  def start(_, _) do
    GenServer.start(ChatGroups, %{})
  end

  def start_link(chat_group_id, info) do
    GenServer.start_link(__MODULE__,
    {chat_group_id, info},
     name: {:via, Horde.Registry, {@chat_group_registry_name, chat_group_id, "chat_group_#{chat_group_id}"}}
    )
  end

  # child spec
  def child_spec({chat_group_id, info}) do
    %{
      id: "chat_group_#{chat_group_id}",
      start: {__MODULE__, :start_link, [chat_group_id, info]},
      type: :worker,
      restart: :transient
    }
  end

  # registry lookup handler
  def via_tuple(chat_group_id), do: {:via, Horde.Registry, {@chat_group_registry_name, chat_group_id}}

  def whereis(chat_group_id) do
    case Registry.lookup(@chat_group_registry_name, chat_group_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def init({chat_group_id, chat_group_state}) do

    chat_group_state = %ChatGroups.State{
      id: chat_group_id,
      messages: chat_group_state.messages ,
      participants: chat_group_state.participants,
      admins:  chat_group_state.admins
    }

    {:ok, {chat_group_id, chat_group_state}}
  end

  ## Callbacks

  def handle_call(:get_messages, _from, {chat_group_id, chat_group_state}) do
    {:reply, chat_group_state.messages, {chat_group_id, chat_group_state}}
  end

  # def handle_cast({:add_message, message = %Message{}}, {chat_group_id, chat_group_state}) do
  #   new_messages = save_message(chat_group_state.messages, message)
  #   if Message.secure?(message) do
  #     MessageCleanup.start_link_cleanup(self(), message)
  #   end
  #   Notifications.Task.start_link(chat_group_id, message.receiver)
  #   {:noreply, {chat_group_id, chat_group_state}}
  # end

  # defp save_message(messages = %{}, message = %Message{}) do
  #   # agregar aca la replicación en Crdt despues
  #   Map.put(messages, message.id, message)
  # end

  def handle_call(:get_participants, _from, {chat_group_id, chat_group_state}) do
    {:reply, chat_group_state.participants, {chat_group_id, chat_group_state}}
  end

  def handle_call({:add_participant, admin, participant}, _from, {chat_group_id, chat_group_state}) do
    case find_admin(admin, {chat_group_id, chat_group_state}) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, {chat_group_id, chat_group_state}}
      _admin ->
        new_participants = chat_group_state.participants ++ [participant]
        new_state = %ChatGroups.State{chat_group_state | participants: new_participants}
        {:reply, new_participants, {chat_group_id, new_state}}
    end
  end

  def handle_call({:delete_participant, admin, participant}, _from, {chat_group_id, chat_group_state}) do
    case find_admin(admin, {chat_group_id, chat_group_state}) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, {chat_group_id, chat_group_state}}
      _admin ->
        new_participants =
          case find_participant(participant, {chat_group_id, chat_group_state}) do
            nil -> chat_group_state.participants
            _participant -> Enum.reject(chat_group_state.participants, &(&1 == participant))
          end

        new_state = %ChatGroups.State{chat_group_state | participants: new_participants}
        {:reply, new_participants, {chat_group_id, new_state}}
    end
  end


  def handle_call({:give_administrator_privileges, admin, participant}, _from, {chat_group_id, chat_group_state}) do
    case find_admin(admin, {chat_group_id, chat_group_state}) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, {chat_group_id, chat_group_state}}
      _admin ->
        new_participants =
          case find_participant(participant, {chat_group_id, chat_group_state}) do
            nil -> chat_group_state.participants ++ [participant]
            _participant -> chat_group_state.participants
          end

        new_admins = chat_group_state.admins ++ [participant]
        new_state = %ChatGroups.State{chat_group_state | participants: new_participants, admins: new_admins}
        {:reply, new_admins, {chat_group_id, new_state}}
    end
  end


  def handle_call(:get_admins, _from, {chat_group_id, chat_group_state}) do
    {:reply, chat_group_state.admins, {chat_group_id, chat_group_state}}
  end


  # --- funciones de uso ---

  def get_messages(chat_group_pid) do
    GenServer.call(chat_group_pid, :get_messages)
  end

  def add_message(chat_group_pid, message) do
    GenServer.cast(chat_group_pid, {:add_message, message})
  end

  def modify_message(chat_group_pid, message_id, new_text) do
    GenServer.cast(chat_group_pid, {:modify_message, message_id, new_text})
  end

  def delete_message(chat_group_pid, message_id) do
    GenServer.cast(chat_group_pid, {:delete_message, message_id})
  end

  def get_participants(chat_group_pid) do
    GenServer.call(chat_group_pid, :get_participants)
  end

  def add_participant(chat_group_pid, admin, participant) do
    GenServer.call(chat_group_pid, {:add_participant, admin, participant})
  end

  def delete_participant(chat_group_pid, admin, participant) do
    GenServer.call(chat_group_pid, {:delete_participant, admin, participant})
  end

  def get_admins(chat_group_pid) do
    GenServer.call(chat_group_pid, :get_admins)
  end

  def give_administrator_privileges(chat_group_pid, admin, participant) do
    GenServer.call(chat_group_pid, {:give_administrator_privileges, admin, participant})
  end

  ## Auxiliares

  defp find_admin(user_id, {_, %ChatGroups.State{admins: admins}}) do
    Enum.find(admins, &(&1 == user_id))
  end

  defp find_participant(user_id, {_, %ChatGroups.State{participants: participants}}) do
    Enum.find(participants, &(&1 == user_id))
  end

end
