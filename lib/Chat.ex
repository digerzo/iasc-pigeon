defmodule Chat do
  defmodule State do
    defstruct messages: %{}, secure: false
  end

  use GenServer

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_, _) do
    GenServer.start(Chat, [], [])
  end

  def start_link(state, name) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  ## Callbacks

  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
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
        updated_messages = Map.update!(state.messages, message_id, fn _ -> updated_message end)
        {:noreply, %State{state | messages: updated_messages}}
    end
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

end
