defmodule Pigeon.Application do
  use Application

  def start(_type, _args) do

    children = [
      {Cluster.Supervisor, [topologies(), [name: Pigeon.ClusterSupervisor]]},
      Chats.ChatSupervisor,
      Pigeon.NodeObserver.Supervisor
    ]

    opts = [strategy: :one_for_one, max_seconds: 5, max_restarts: 3]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      key: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
