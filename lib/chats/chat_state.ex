defmodule ChatState do
  defstruct [:id, :agent_pid, :notification_agent_pid, :message_cleanup_pid]
end
