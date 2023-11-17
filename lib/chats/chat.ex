defmodule Chat do
  use GenServer
  require Logger

  def start(_, _) do
    GenServer.start(Chat, %{})
  end

  def start_link(state, name) do
    GenServer.start_link(__MODULE__,
     %ChatState{agent_pid: state.agent_pid, message_cleanup_pid: state.message_cleanup_pid},
      name: name)
  end

  def init(state) do
    {:ok, state}
  end

  ## Callbacks

  def handle_call(:get_messages, _from, state) do
    {:reply, Chats.ChatAgent.get_messages(state.agent_pid), state}
  end

  def handle_cast({:send_message, message = %Message{}}, state) do
    Chats.ChatAgent.add_message(state.agent_pid, message)
    {:noreply, state}
  end

  def handle_cast({:modify_message, message_id, new_text}, state) do
    Chats.ChatAgent.modify_message(state.agent_pid, message_id, new_text)
    {:noreply, state}
  end

  def handle_cast({:delete_message, message_id}, state) do
    Chats.ChatAgent.delete_message(state.agent_pid, message_id)
    {:noreply, state}
  end

  def handle_cast({:delete_messages, message_ids}, state) do
    Chats.ChatAgent.delete_messages(state.agent_pid, message_ids)
    {:noreply, state}
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
