defmodule UserState do
  defstruct [:id, :agent_pid]

  def new(id, agent_pid) do
    %UserState{id: id, agent_pid: agent_pid}
  end
end
