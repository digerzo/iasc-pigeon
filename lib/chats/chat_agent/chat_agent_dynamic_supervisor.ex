defmodule Chats.AgentDynamicSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def which_children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def start_child(initial_state, name) do
    spec = %{
      id: Chats.Agent,
      start: {Chats.Agent, :start_link, [initial_state, name]}
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
