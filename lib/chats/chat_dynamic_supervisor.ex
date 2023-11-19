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

  def start_child do
    chat_id = App.Utils.random_string(10)
    #Ejemplo para agregar chats:
    # {:ok, pid} = Chats.ChatDynamicSupervisor.start_child()
    spec = { Chat, { chat_id, %{}} }
    {:ok, _child_pid} = DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
