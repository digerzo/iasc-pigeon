defmodule User.State do
  defstruct [:id, :agent_pid]

  def new(id, agent_pid) do
    %User.State{id: id, agent_pid: agent_pid}
  end
end
