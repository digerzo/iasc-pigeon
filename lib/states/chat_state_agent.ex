defmodule States.ChatStateAgent do
  use Agent

  def start_link(state) do
    Agent.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get(agent, key) do
    Agent.get(agent, &Map.get(&1, key))
  end

  # fn map -> Map.put(map, key, value) end
  def put(agent, key, value) do
    Agent.update(agent, &Map.put(&1, key, value))
  end

end
