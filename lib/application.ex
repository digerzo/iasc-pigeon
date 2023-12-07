defmodule Pigeon.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Chats.Supervisor,
      Notifications.Supervisor,
      Chats.AgentSupervisor,
    ]

    opts = [strategy: :one_for_one, name: Pigeon.Supervisor, max_seconds: 5, max_restarts: 3]
    Supervisor.start_link(children, opts)
  end

end
