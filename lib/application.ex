defmodule Pigeon.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      %{id: Chats.Supervisor, start: {Chats.Supervisor, :start_link, [[]]} },
    ]

    opts = [strategy: :one_for_one, max_seconds: 5, max_restarts: 3]
    Supervisor.start_link(children, opts)
  end

end
