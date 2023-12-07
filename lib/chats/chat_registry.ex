defmodule Chats.Registry do
  use Horde.Registry

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

  def find_or_create_process(chat_id) do
    if account_process_exists?(chat_id) do
      {:ok, Horde.Registry.lookup(__MODULE__, chat_id) |> List.first |> elem(0) }
    else
      Chats.DynamicSupervisor.start_child(chat_id)
    end
  end

  def find_or_create(users) do
    sorted = Enum.sort(users)
    [first, second] = sorted
    key = :"chat_#{first}_#{second}"
    find_or_create_process(key)
  end

  def account_process_exists?(chat_id) do
    case Horde.Registry.lookup(__MODULE__, chat_id) do
      [] -> false
      _ -> true
    end
  end

  @spec chat_ids() :: list()
  def chat_ids do
    Chats.DynamicSupervisor.which_children
    |> Enum.map(fn {_, chat_proc_pid, _, _} ->
      Horde.Registry.keys(__MODULE__, chat_proc_pid)
      |> List.first
    end)
    |> Enum.sort
  end

end

#Chats.RegistrySupervisorWrapper.find_or_create_process("becb8b242d")
#Chats.RegistrySupervisorWrapper.find_or_create_process(2)
#Chats.RegistrySupervisorWrapper.find_or_create_process(3)
#{ok, pid} = Chats.RegistrySupervisorWrapper.find_or_create_process(1)
