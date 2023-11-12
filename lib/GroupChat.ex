defmodule GroupChat do
  defmodule State do
    defstruct admin: nil, members: %{}, messages: %{}
  end

  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
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

  def add_member(chat_pid, user) do
    GenServer.cast(chat_pid, {:add_member, user})
  end

  def remove_member(chat_pid, user) do
    GenServer.cast(chat_pid, {:remove_member, user})
  end

  def grant_admin_privileges(chat_pid, user) do
    GenServer.cast(chat_pid, {:grant_admin_privileges, user})
  end

  def handle_cast({:send_message, message = %Message{}}, state) do
    updated_messages = Map.put(state.messages, message.id, message)
    {:noreply, %State{state | messages: updated_messages}}
  end

  def handle_cast({:modify_message, message_id, new_text}, state) do
    case Map.get(state.messages, message_id) do
      nil -> {:noreply, state}
      message ->
        updated_message = %{message | text: new_text}
        updated_messages = Map.update!(state.messages, message_id, &updated_message/1)
        {:noreply, %State{state | messages: updated_messages}}
    end
  end

  def handle_cast({:delete_message, message_id}, state) do
    updated_messages = Map.delete(state.messages, message_id)
    {:noreply, %State{state | messages: updated_messages}}
  end

  def handle_cast({:add_member, user}, state) do
    updated_members = Map.put(state.members, user.id, user)
    {:noreply, %State{state | members: updated_members}}
  end

  def handle_cast({:remove_member, user}, state) do
    updated_members = Map.delete(state.members, user.id)
    {:noreply, %State{state | members: updated_members}}
  end

  def handle_cast({:grant_admin_privileges, user}, state) do
    {:noreply, %State{state | admin: user.id}}
  end
end
