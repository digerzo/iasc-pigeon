defmodule Chats.ChatDynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 4, max_seconds: 5)
  end

  def which_children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  def start_child({agent_pid, message_cleanup_pid}) do
    chat_id = App.Utils.random_string(10)
    #Ejemplo para agregar accounts:
    # {:ok, chat_agent} = Chats.ChatAgent.start_link(%{}, ChatAgent)
    # {:ok, message_cleanup} = MessageCleanup.start_link(%{}, MessageCleanup)
    # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child( { chat_agent, message_cleanup } )
    spec = {Chat, { chat_id, { agent_pid, message_cleanup_pid }} }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
