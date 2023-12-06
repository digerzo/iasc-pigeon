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

  #Ejemplo para agregar chats:
  # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child()
  def start_child do
    chat_id = App.Utils.random_string(10)
    {:ok, agent_pid} = Chats.ChatAgentDynamicSupervisor.start_child(%{},:"chat_agent_#{chat_id}")
    spec = {Chat, {chat_id, %{agent_pid: agent_pid}}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child(:chat_agus_walter)
  def start_child(chat_id) do
    # {:ok, agent_pid} = Chats.ChatAgentDynamicSupervisor.start_child(%{},:"chat_agent_#{chat_id}")
    spec = {Chat, {chat_id, %{}}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
