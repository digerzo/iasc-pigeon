defmodule Chat do
  use GenServer
  require Logger

  @chat_registry_name :chat_registry_name

  def start(_, _) do
    GenServer.start(Chat, %{})
  end

  def start_link(chat_id, info) do
    GenServer.start_link(__MODULE__,
    {chat_id, info},
     name: {:via, Registry, {@chat_registry_name, chat_id, "Chat#{chat_id}"}}
    )
  end

  # child spec
  def child_spec({chat_id, info}) do
    %{
      id: "chat#{chat_id}",
      start: {__MODULE__, :start_link, [chat_id, info]},
      type: :worker,
      restart: :transient
    }
  end

  # registry lookup handler
  def via_tuple(chat_id), do: {:via, Registry, {@chat_registry_name, chat_id}}

  def whereis(chat_id) do
    case Registry.lookup(@chat_registry_name, chat_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def init({chat_id, _ }) do
    # {agent_pid, message_cleanup_pid} = info
    {:ok, agent_pid } = Chats.ChatAgent.start_link(%{}, ChatAgent)
    {:ok, message_cleanup_pid} = MessageCleanup.start_link(%{}, MessageCleanup)

    chat_state = %ChatState{
      id: chat_id,
      agent_pid: agent_pid,
      message_cleanup_pid: message_cleanup_pid
    }

    {:ok, {chat_id, chat_state}}
  end

  ## Callbacks

  # Chat.get_messages(pid)
  def handle_call(:get_messages, _from, { _ , chat_state}) do
    {:reply, Chats.ChatAgent.get_messages(chat_state.agent_pid), chat_state}
  end

  # Chat.send_message(pid, Message.new("Hola", %User{id: "lauti"}, %User{id: "agus"}))
  def handle_cast({:send_message, message = %Message{}}, {chat_id, chat_state}) do
    Chats.ChatAgent.add_message(chat_state.agent_pid, message)
    {:noreply, {chat_id, chat_state}}
  end

  # Chat.modify_message(pid, 1700247261156, "AAAAAAAAA")
  def handle_cast({:modify_message, message_id, new_text}, {chat_id, chat_state}) do
    Chats.ChatAgent.modify_message(chat_state.agent_pid, message_id, new_text)
    {:noreply, {chat_id, chat_state}}
  end

  # Chat.delete_message(pid, 1700247261156)
  def handle_cast({:delete_message, message_id}, {chat_id, chat_state}) do
    Chats.ChatAgent.delete_message(chat_state.agent_pid, message_id)
    {:noreply, {chat_id, chat_state}}
  end

  # Chat.delete_messages(pid,[1700246636182, 1700246642924, 1700246652675, 1700246653110])
  def handle_cast({:delete_messages, message_ids}, {chat_id, chat_state}) do
    Chats.ChatAgent.delete_messages(chat_state.agent_pid, message_ids)
    {:noreply, {chat_id, chat_state}}
  end

  # --- funciones de uso ---

  def get_messages(chat_pid) do
    GenServer.call(chat_pid, :get_messages)
  end

  def send_message(chat_pid, message) do
    GenServer.cast(chat_pid, {:send_message, message})
  end

  def modify_message(chat_pid, message_id, new_text) do
    GenServer.cast(chat_pid, {:modify_message, message_id, new_text})
  end

  def delete_message(chat_pid, message_id) do
    GenServer.cast(chat_pid, {:delete_message, message_id})
  end

  def delete_messages(chat_pid, message_ids) do
    GenServer.cast(chat_pid, {:delete_messages, message_ids})
  end


end
