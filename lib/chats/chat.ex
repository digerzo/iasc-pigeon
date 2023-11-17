defmodule Chat do
  use GenServer
  require Logger

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_, _) do
    GenServer.start(Chat, %ChatState{})
  end

  def start_link(state, name) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    %ChatState{messages: messages} = state

    # Crea el estado del chat
    chat_state = %ChatState{
      messages: messages
    }

    # Linkeo proceso limpiador de mensajes
    {:ok, _ } = MessageCleanup.start_link(%{}, MessageCleanup )

    {:ok, chat_state}
  end

  ## Callbacks

  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_cast({:send_message, message = %Message{}}, state) do
    # Desestructurar el estado para obtener los mensajes
    %ChatState{messages: current_messages} = state
    updated_messages = Map.put(current_messages, message.id, message)
    new_state = %ChatState{state | messages: updated_messages}
    # En vez de self() debería mandarse el pid destino. Cómo lo obtenemos?
    # Notification.send_notification(self(), message)
    {:noreply, new_state}
  end

  def handle_cast({:modify_message, message_id, new_text}, state) do
    # Logger.info("Se modifica el mensaje con ID: #{message_id}.")
    %ChatState{messages: current_messages} = state
    # Obtengo mensaje de la lista de mensajes
    case Map.get(current_messages, message_id) do
      nil -> {:noreply, state}
      message ->
        updated_message = %{message | text: new_text}
        updated_messages = Map.update!(current_messages, message_id, fn _ -> updated_message end)
        {:noreply, %ChatState{state | messages: updated_messages}}
    end
  end

  def handle_cast({:delete_message, message_id}, state) do
    %ChatState{messages: current_messages} = state
    case Map.get(current_messages, message_id) do
      nil -> {:noreply, state}
      _ ->
        updated_messages = Map.delete(current_messages, message_id)
        {:noreply, %ChatState{state | messages: updated_messages}}
      end
  end

  def handle_info({:new_message, message}) do
    IO.puts(message)
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

  def new_message(chat_pid, message) do
    GenServer.info(chat_pid, {:new_message, message})
  end

  # Función para limpiar mensajes expirados
  # def cleanup_expired_messages(chat_pid) do
  #   GenServer.cast(pid, :cleanup_expired_messages)
  # end

end
