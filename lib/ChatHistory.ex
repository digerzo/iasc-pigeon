defmodule ChatHistory do
  use Agent

  def start_link(state) do
    Agent.start_link(fn -> %State{history: state} end, name: __MODULE__)
  end

  def add_message(agent_pid, user_id, message) do
    Agent.update(agent_pid, fn state ->
      updated_history = Map.update(state.history, user_id, [message], &[message | &1])
      %State{state | history: updated_history}
    end)
  end

  def get_history(agent_pid, user_id) do
    Agent.get(agent_pid, fn state ->
      Map.get(state.history, user_id, [])
    end)
  end
end
