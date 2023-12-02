defmodule UserState do
  defstruct [:id, :agent_pid, :user_name]

  def new(id, agent_pid, user_name) do
    %UserState{id: id, agent_pid: agent_pid, user_name: user_name}
  end
end
