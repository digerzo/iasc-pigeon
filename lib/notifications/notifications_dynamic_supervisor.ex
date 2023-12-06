defmodule Notifications.NotificationsDynamicSupervisor do
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

  # Notifications.NotificationsDynamicSupervisor.start_child(:algo)
  def start_child(name) do
    spec = %{
      id: Notifications,
      start: {Notifications, :start_link, [%{},name]}
    }

    Horde.DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
