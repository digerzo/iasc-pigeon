defmodule States.ChatStateStorage do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    # Iniciar el agente de estado
    {:ok, agent_pid} = Agent.start_link(fn -> %{} end)

    # Devolver el estado inicial
    {:ok, %{state_agent: agent_pid}}
  end

  # Funciones para interactuar con el GenServer

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def store_state(pid, key, value) do
    GenServer.cast(pid, {:store_state, key, value})
  end

  # Callbacks del GenServer

  def handle_call(:get_state, _from, state) do
    {:reply, Agent.get(state.state_agent, & &1), state}
  end

  def handle_cast({:store_state, key, value}, state) do
    new_state = Agent.update(state.state_agent, &Map.put(&1, key, value))
    {:noreply, %{state | state_agent: new_state}}
  end

end
