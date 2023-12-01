defmodule Chats.ChatSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do

    children = [
      #%{id: Chats.ChatDynamicSupervisor, start: {Chats.ChatDynamicSupervisor, :start_link, [[]]} },
      Chats.ChatDynamicSupervisor,
      Chats.Registry,
      #%{id: Chats.ChatAgentDynamicSupervisor, start: {Chats.ChatAgentDynamicSupervisor, :start_link, [[]]} },
      Chats.ChatAgentDynamicSupervisor,
      Chats.AgentRegistry,
      Notifications.NotificationsDynamicSupervisor,
      Notifications.NotificationsRegistry
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end
end
