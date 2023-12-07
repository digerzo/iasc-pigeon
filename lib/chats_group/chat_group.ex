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
  def child_spec(%{id: chat_group_id, owner: owner}) do
    state = ChatGroups.State.new(chat_group_id, owner)
    %{
      id: "chat_group_#{chat_group_id}",
      start: {__MODULE__, :start_link, [chat_group_id, state]},
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
    case Chats.Crdt.get_state(chat_group_id) do
      nil -> {:ok, %ChatGroups.State{
        id: chat_group_id,
        messages: chat_group_state.messages ,
        participants: chat_group_state.participants,
        admins:  chat_group_state.admins
      }}
      existing_state ->{:ok, existing_state}
    end
  end

  ## Callbacks

  # ChatGroups.get_messages(grupo)
  def handle_call(:get_messages, _from, chat_group_state) do
    {:reply, chat_group_state.messages, chat_group_state}
  end

  # ChatGroups.add_message(grupo, Message.new("Hola", "agus", "lospibes"))
  def handle_cast({:add_message, message = %Message{}}, chat_group_state) do
    new_state = save_message(chat_group_state, message)
    if Message.secure?(message) do
      MessageCleanup.start_link_cleanup(self(), message)
    end
    notify_participants(chat_group_state)
    {:noreply, new_state}
  end

  # ChatGroups.modify_message(grupo,"QTy6oPagLyc=","HOLAAAA")
  def handle_cast({:modify_message, message_id, new_text}, chat_group_state) do
    new_state = update_message(chat_group_state, message_id, new_text)
    {:noreply, new_state}
  end

  # ChatGroups.delete_message(grupo,"QTy6oPagLyc=")
  def handle_cast({:delete_message, message_id}, chat_group_state) do
    new_state = remove_message(chat_group_state, message_id)
    {:noreply, new_state}
  end

  # ChatGroups.get_participants(grupo)
  def handle_call(:get_participants, _from, chat_group_state) do
    {:reply, chat_group_state.participants, chat_group_state}
  end

  # ChatGroups.add_participant(grupo, "user1", "user2") -> user1 siendo admin.
  def handle_call({:add_participant, admin, participant}, _from, chat_group_state) do
    case find_admin(admin, chat_group_state) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, chat_group_state}
      _admin ->
        new_participants = chat_group_state.participants ++ [participant]
        new_state = %ChatGroups.State{chat_group_state | participants: new_participants}
        Chats.Crdt.save_state(chat_group_state.id, new_state)
        {:reply, new_participants, new_state}
    end
  end

  # ChatGroups.delete_participant(grupo, "user1", "user2") -> user1 siendo admin.
  def handle_call({:delete_participant, admin, participant}, _from, chat_group_state) do
    case find_admin(admin, chat_group_state) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, chat_group_state}
      _admin ->
        new_participants = Enum.reject(chat_group_state.participants, &(&1 == participant))
        new_admins = Enum.reject(chat_group_state.admins, &(&1 == participant))
        new_state = %ChatGroups.State{chat_group_state | participants: new_participants, admins: new_admins }
        Chats.Crdt.save_state(chat_group_state.id, new_state)
        {:reply, new_participants, new_state}
    end
  end

  def handle_call({:give_administrator_privileges, admin, participant}, _from, chat_group_state) do
    case find_admin(admin, chat_group_state) do
      nil -> {:reply, {:error, "User '#{admin}' no privileges"}, chat_group_state}
      _admin ->
        new_participants =
          case find_participant(participant, chat_group_state) do
            nil -> chat_group_state.participants ++ [participant]
            _participant -> chat_group_state.participants
          end

        new_admins = chat_group_state.admins ++ [participant]
        new_state = %ChatGroups.State{chat_group_state | participants: new_participants, admins: new_admins}
        Chats.Crdt.save_state(chat_group_state.id, new_state)
        {:reply, new_admins,  new_state}
    end
  end

  # ChatGroups.get_admins(grupo)
  def handle_call(:get_admins, _from, chat_group_state) do
    {:reply, chat_group_state.admins, chat_group_state}
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

  ## Auxiliares o privadas

  defp find_admin(user_id, %ChatGroups.State{admins: admins}) do
    Enum.find(admins, &(&1 == user_id))
  end

  defp find_participant(user_id, %ChatGroups.State{participants: participants}) do
    Enum.find(participants, &(&1 == user_id))
  end

  defp save_message(chat_group_state = %ChatGroups.State{}, message = %Message{}) do
    new_messages = Map.put(chat_group_state.messages, message.id, message)
    new_state = %ChatGroups.State{chat_group_state | messages: new_messages}
    Chats.Crdt.save_state(chat_group_state.id, new_state)
    new_state
  end

  defp update_message(chat_group_state = %ChatGroups.State{}, message_id, new_text) do
    new_messages = Map.update!(chat_group_state.messages, message_id, fn message -> Map.put(message, :text, new_text) end)
    new_state = %ChatGroups.State{chat_group_state | messages: new_messages}
    Chats.Crdt.save_state(chat_group_state.id, new_state)
    new_state
  end

  defp remove_message(chat_group_state = %ChatGroups.State{}, message_id) do
    new_messages = Map.delete(chat_group_state.messages, message_id)
    new_state = %ChatGroups.State{chat_group_state | messages: new_messages}
    Chats.Crdt.save_state(chat_group_state.id, new_state)
    new_state
  end

  defp notify_participants(chat_group_state) do
    Enum.each(chat_group_state.participants, fn participant ->
      Notifications.Task.start_link(chat_group_state.id, participant)
    end)
  end

end
