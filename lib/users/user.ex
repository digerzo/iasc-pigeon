defmodule User do
  use GenServer
  require Logger

  def start_link(user_id, info, name) do
    GenServer.start_link(__MODULE__, {user_id, info}, name: name)
  end

  def init({user_id, info}) do
    user_state = %UserState{
      id: user_id,
      agent_pid: info.agent_pid
    }

    {:ok, {user_state}}
  end

  # --- Callbacks ---

  def handle_call({:get_messages, chat_pid}, _from, {user_state}) do
    #{:ok, chat_pid} = find_chat(user_state.user_name, message.receiver.user_name)
    {:reply, Chat.get_messages(chat_pid), {user_state}}
  end

  def handle_cast({:add_message, message = %Message{}, chat_pid}, {user_state}) do
    #{:ok, chat_pid} = find_chat(user_state.user_name, message.receiver.user_name)
    Chat.add_message(chat_pid, message)
    {:noreply, {user_state}}
  end

  def handle_cast({:modify_message, message_id, new_text, receiver = %UserState{}, chat_pid}, {user_state}) do
    #{:ok, chat_pid} = find_chat(user_state.user_id, receiver.user_id)
    Chat.modify_message(chat_pid, message_id, new_text)
    {:noreply, {user_state}}
  end

  def handle_cast({:delete_message, message_id, receiver = %UserState{}, chat_pid}, {user_state}) do
    #{:ok, chat_pid} = find_chat(user_state.user_id, receiver.user_id)
    Chat.delete_message(chat_pid, message_id)
    {:noreply, {user_state}}
  end

  def handle_cast({:delete_messages, message_ids, receiver = %UserState{}, chat_pid}, {user_state}) do
    #{:ok, chat_pid} = find_chat(user_state.user_id, receiver.user_id)
    Chat.delete_messages(chat_pid, message_ids)
    {:noreply, {user_state}}
  end

  def handle_call({:get_notifications}, _from, {user_state}) do
    {:reply, Notifications.get_notifications(user_state.agent_pid), {user_state}}
  end

  # --- Funciones ---

  def read_messages(user_pid, chat_pid) do
    GenServer.call(user_pid, {:get_messages, chat_pid})
  end

  def send_message(user_pid, message, chat_pid) do
    GenServer.cast(user_pid, {:add_message, message, chat_pid})
  end

  def modify_message(user_pid, message_id, new_text, receiver, chat_pid) do
    GenServer.cast(user_pid, {:modify_message, message_id, new_text, receiver, chat_pid})
  end

  def delete_message(user_pid, message_id, receiver, chat_pid) do
    GenServer.cast(user_pid, {:delete_message, message_id, receiver, chat_pid})
  end

  def delete_messages(user_pid, message_ids, receiver, chat_pid) do
    GenServer.cast(user_pid, {:delete_messages, message_ids, receiver, chat_pid})
  end

  def read_notifications(user_pid) do
    GenServer.call(user_pid, {:get_notifications})
  end

  def find_chat(sender_id, receiver_id) do
    Chats.Registry.find_or_create_chat(sender_id, receiver_id)
  end
end
