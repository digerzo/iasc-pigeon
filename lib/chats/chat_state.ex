defmodule Chats.State do
  defstruct [:id, :agent_pid, :message_cleanup_pid]
end
