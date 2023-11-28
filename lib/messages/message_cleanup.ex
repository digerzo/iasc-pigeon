defmodule MessageCleanup do
  use Task
  require Logger

  def start_link_cleanup(chat_pid, message) do
    Task.start_link(__MODULE__, :cleanup, [chat_pid, message])
  end

  def cleanup(chat_pid, message) do
    #Logger.debug("Cleanup initiated. Message: #{inspect(message)}, Chat PID: #{inspect(chat_pid)}")
    Process.send_after(chat_pid, {:cleanup_message, message.id}, message.expiration_time)
    {:ok}
  end
end
