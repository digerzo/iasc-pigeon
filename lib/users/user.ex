defmodule User do
  use GenServer

  def log_in(user_id) do
    start_link(user_id)
  end

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, {user_id}, name: :"user_#{user_id}")
  end

  def init({user_id}) do
    {:ok, notification_agent_pid} = Notifications.DynamicSupervisor.start_child(user_id)
    user_state = %User.State{
      id: user_id,
      agent_pid: notification_agent_pid,
    }
    {:ok, {user_state}}
  end

  # --- Callbacks ---

  def handle_call({:get_messages, receiver}, _from, {user_state}) do
    {:ok, chat_pid} = find_chat(user_state.id, receiver)
    {:reply, Chats.get_messages(chat_pid), {user_state}}
  end

  def handle_cast({:add_message, message = %Message{}}, {user_state}) do
    {:ok, chat_pid} = find_chat(user_state.id, message.receiver)
    Chats.add_message(chat_pid, message)
    {:noreply, {user_state}}
  end

  def handle_cast({:modify_message, message_id, new_text, receiver}, {user_state}) do
    {:ok, chat_pid} = find_chat(user_state.id, receiver)
    Chats.modify_message(chat_pid, message_id, new_text)
    {:noreply, {user_state}}
  end

  def handle_cast({:delete_message, message_id, receiver}, {user_state}) do
    {:ok, chat_pid} = find_chat(user_state.id, receiver)
    Chats.delete_message(chat_pid, message_id)
    {:noreply, {user_state}}
  end

  def handle_cast({:delete_messages, message_ids, receiver}, {user_state}) do
    {:ok, chat_pid} = find_chat(user_state.id, receiver)
    Chats.delete_messages(chat_pid, message_ids)
    {:noreply, {user_state}}
  end

  def handle_call({:get_notifications}, _from, {user_state}) do
    {:reply, Notifications.Agent.read_notifications(user_state.agent_pid), {user_state}}
  end

  # --- Funciones ---

  def read_messages(user_pid, receiver) do
    GenServer.call(user_pid, {:get_messages, receiver})
  end

  def send_message(user_pid, message) do
    GenServer.cast(user_pid, {:add_message, message})
  end

  def modify_message(user_pid, message_id, new_text, receiver) do
    GenServer.cast(user_pid, {:modify_message, message_id, new_text, receiver})
  end

  def delete_message(user_pid, message_id, receiver) do
    GenServer.cast(user_pid, {:delete_message, message_id, receiver})
  end

  def delete_messages(user_pid, message_ids, receiver) do
    GenServer.cast(user_pid, {:delete_messages, message_ids, receiver})
  end

  def read_notifications(user_pid) do
    GenServer.call(user_pid, {:get_notifications})
  end

  def find_chat(sender_id, receiver_id) do
    users = [sender_id, receiver_id]
    Chats.Registry.find_or_create(users)
  end
end
