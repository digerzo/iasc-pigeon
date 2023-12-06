defmodule Chats.ChatDynamicSupervisor do
  use Horde.DynamicSupervisor

  def start_link(opts) do
    Horde.DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(init_arg) do
    [
      members: members(),
      strategy: :one_for_one,
      distribution_strategy: Horde.UniformQuorumDistribution,
      process_redistribution: :active
    ]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  defp members do
    Enum.map(Node.list([:this, :visible]), &{__MODULE__, &1})
  end

  def which_children do
    Horde.DynamicSupervisor.which_children(__MODULE__)
  end

  #Ejemplo para agregar chats:
  # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child()
  def start_child do
    chat_id = App.Utils.random_string(10)
    {:ok, agent_pid} = Chats.ChatAgentDynamicSupervisor.start_child(%{},:"chat_agent_#{chat_id}")
    spec = {Chat, {chat_id, %{agent_pid: agent_pid}}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child(:chat_agus_walter)
  def start_child(chat_id) do
    # {:ok, agent_pid} = Chats.ChatAgentDynamicSupervisor.start_child(%{},:"chat_agent_#{chat_id}")
    spec = {Chat, {chat_id, %{}}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
