defmodule Chats.ChatAgentRegistry do

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
    if chat_agent_exists?(chat_id) do
      # Registry.lookup(:account_main_registry, chat_id)
      {:ok, Horde.Registry.lookup(__MODULE__, chat_id) |> List.first |> elem(0) }
    else
      Chats.ChatAgentDynamicSupervisor.start_child(chat_id)
    end
  end

  def chat_agent_exists?(chat_id) do
    case Horde.Registry.lookup(__MODULE__, chat_id) do
      [] -> false
      _ -> true
    end
  end

end
