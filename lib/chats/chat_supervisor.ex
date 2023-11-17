defmodule Chats.ChatSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, chat_agent} = Chats.ChatAgent.start_link(%{}, ChatAgent)
    {:ok, message_cleanup} = MessageCleanup.start_link(%{}, MessageCleanup)

    children = [
      %{id: Chat, start: {Chat, :start_link, [%ChatState{agent_pid: chat_agent, message_cleanup_pid: message_cleanup}, ChatAgusLauti]}, restart: :transient, name: Chat}
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end
end
