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

  # --- funciones de uso ---

  def get_messages(chat_pid) do
    GenServer.call(chat_pid, :get_messages)
  end

end
