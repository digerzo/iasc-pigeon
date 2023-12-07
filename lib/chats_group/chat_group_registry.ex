defmodule ChatGroups.Registry do

  use Horde.Registry
  require Logger

  def start_link(_init) do
    Horde.Registry.start_link(__MODULE__, [keys: :unique], name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.Registry.init()
  end

  defp members() do
    [Node.self() | Node.list()]
    |> Enum.map(fn node -> {__MODULE__, node} end)
  end

  def find_or_create_process(chat_group_id) do
    if account_process_exists?(chat_group_id) do
      # Registry.lookup(:account_main_registry, chat_group_id)
      {:ok, Horde.Registry.lookup(__MODULE__, chat_group_id) |> List.first |> elem(0) }
    else
      ChatGroups.ChatGroupDynamicSupervisor.start_child(chat_group_id)
    end
  end

  def account_process_exists?(chat_group_id) do
    case Horde.Registry.lookup(__MODULE__, chat_group_id) do
      [] -> false
      _ -> true
    end
  end

  @spec chat_group_ids() :: list()
  def chat_group_ids do
    ChatGroups.ChatGroupDynamicSupervisor.which_children
    |> Enum.map(fn {_, chat_group_proc_pid, _, _} ->
      Horde.Registry.keys(__MODULE__, chat_group_proc_pid)
      |> List.first
    end)
    |> Enum.sort
  end

end
