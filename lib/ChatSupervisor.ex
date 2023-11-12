defmodule ChatSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Chat, [], id: Chat),
      worker(GroupChat, [], id: GroupChat)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
