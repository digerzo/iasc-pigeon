defmodule ChatGroups.ChatGroupDynamicSupervisor do
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

  def start_child(chat_group_id) do
    spec = {ChatGroup, {chat_group_id, %ChatGroupState{}}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
