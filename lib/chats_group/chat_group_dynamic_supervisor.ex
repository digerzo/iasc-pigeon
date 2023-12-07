defmodule ChatGroups.DynamicSupervisor do
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

  def start_child(chat_group_id) do
    spec = {ChatGroups, {chat_group_id, %ChatGroups.State{}}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # {:ok, pid} = ChatGroups.DynamicSupervisor.start_child(:crazy_id, "agus")
  def start_child(chat_group_id, owner) do
    spec = {ChatGroups, %{id: chat_group_id, owner: owner}}
    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
