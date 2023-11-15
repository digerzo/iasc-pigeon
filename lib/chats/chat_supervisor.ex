defmodule Chats.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      %{id: Chat, start: {Chat, :start_link, [%ChatState{ messages: %{}}, ChatAgusLauti]}, restart: :transient}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end
end
