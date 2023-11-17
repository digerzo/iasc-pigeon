defmodule GroupChat do

  use GenServer
  require Logger

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_, _) do
    GenServer.start(Chat, %GroupChatState{})
  end

  def start_link(state, name) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    %GroupChatState{messages: messages, users: users, admins: admins} = state

    # Crea el estado del chat
    group_chat_state = %GroupChatState{
      messages: messages,
      users: users,
      admins: admins
    }

    # Linkeo proceso limpiador de mensajes
    {:ok, _ } = MessageCleanup.start_link(%{}, MessageCleanup )

    {:ok, group_chat_state}
  end

  ## Callbacks

  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
  end

  def handle_cast({:send_message, message = %Message{}}, state) do
    # Desestructurar el estado para obtener los mensajes
    %GroupChatState{messages: current_messages} = state
    updated_messages = Map.put(current_messages, message.id, message)
    new_state = %GroupChatState{state | messages: updated_messages}
    Notification.send_notification(self(), message)
    {:noreply, new_state}
  end

  # --- funciones de uso ---

  def get_messages(chat_pid) do
    GenServer.call(chat_pid, :get_messages)
  end

  def send_message(chat_pid, message) do
    GenServer.cast(chat_pid, {:send_message, message})
  end

end
