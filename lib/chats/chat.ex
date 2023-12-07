defmodule Chats do
  use GenServer
  require Logger

  @chat_registry_name Chats.Registry

  def start(_, _) do
    GenServer.start(Chats, %{})
  end

  def start_link(chat_id, info) do
    GenServer.start_link(
      __MODULE__,
      {chat_id, info},
      name: {:via, Horde.Registry, {@chat_registry_name, chat_id, "chat#{chat_id}"}}
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
  def via_tuple(chat_id), do: {:via, Horde.Registry, {@chat_registry_name, chat_id}}

  def whereis(chat_id) do
    case Registry.lookup(@chat_registry_name, chat_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end


  def init({chat_id, messages}) do
    chat_state = %ChatState{
      id: chat_id,
      messages: messages
    }

    {:ok, chat_state}
  end


  ## Callbacks

  # Chat.get_messages(pid)
  def handle_call(:get_messages, _from, chat_state) do
    {:reply, chat_state.messages, chat_state}
  end

  def handle_info({:cleanup_message, message_id}, %{id: id, messages: messages}) do
    new_messages = remove_message(messages, message_id)
    {:noreply, %{id: id, messages: new_messages}}
  end

  # Chat.add_message(pid, Message.new("Hola", "agus", "walter"))
  def handle_cast({:add_message, message = %Message{}}, %{id: id, messages: messages}) do
    new_messages = save_message(messages, message)
    if Message.secure?(message) do
      MessageCleanup.start_link_cleanup(self(), message)
    end
    Notifications.Task.start_link(message.sender, message.receiver)
    {:noreply, %{id: id, messages: new_messages}}
  end

  defp save_message(messages = %{}, message = %Message{}) do
    # agregar aca la replicación en Crdt despues
    Map.put(messages, message.id, message)
  end

  # Chat.modify_message(pid,"AiMASfBwwYE=", "AAAAAAAAA")
  def handle_cast({:modify_message, message_id, new_text}, %{id: id, messages: messages}) do
    new_messages = update_message(messages, message_id, new_text)
    {:noreply, %{id: id, messages: new_messages}}
  end

  defp update_message(messages, message_id, new_text) do
    # agregar actualizar en el crdt
    Map.update!(messages, message_id, fn message -> Map.put(message, :text, new_text) end)
  end

  # Chat.delete_message(pid, 1700247261156)
  def handle_cast({:delete_message, message_id}, %{id: id, messages: messages}) do
    new_messages = remove_message(messages, message_id)
    {:noreply, %{id: id, messages: new_messages}}
  end

  defp remove_message(messages = %{}, message_id) do
    Map.delete(messages, message_id)
  end

  # Chat.delete_messages(pid,[1700246636182, 1700246642924, 1700246652675, 1700246653110])
  def handle_cast({:delete_messages, message_ids}, %{id: id, messages: messages}) do
    new_messages = remove_messages(messages, message_ids)
    {:noreply, %{id: id, messages: new_messages}}
  end

  defp remove_messages(messages = %{}, message_ids) do
    Enum.reduce(message_ids, messages, fn message_id, acc_state ->
      Map.delete(acc_state, message_id)
    end)

  end

  def handle_info(:end_process, chat_state) do
    Logger.info("Process terminating... Chat ID: #{chat_state.id}")
    {:stop, :normal, chat_state}
  end

  def handle_info(:kill_process, chat_state) do
    Logger.info("Killing Process... Chat ID: #{chat_state.id}")
    {:stop, :kill , chat_state}
  end

  # --- funciones de uso ---

  def get_messages(chat_pid) do
    GenServer.call(chat_pid, :get_messages)
  end

  def add_message(chat_pid, message) do
    GenServer.cast(chat_pid, {:add_message, message})
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

  def close_chat(chat_id) do
    Process.send_after(chat_id, :end_process, 0)
  end

  def kill_process(chat_id) do
    Process.send_after(chat_id, :kill_process, 0)
  end


end
