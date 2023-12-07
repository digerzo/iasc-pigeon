defmodule Notifications.Registry do
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

  def find_or_create(user) do
    key = "notification_agent_#{user}"
    find_or_create_process(key, user)
  end

  # { :ok, pid } = Notifications.NotificationsRegistry.find_or_create_process("agent_notif_lauti")
  def find_or_create_process(agent_notifications_id, user) do
    if notification_agent_process_exists?(agent_notifications_id) do
      {:ok, Horde.Registry.lookup(__MODULE__, agent_notifications_id) |> List.first |> elem(0) }
    else
      Notifications.DynamicSupervisor.start_child(user)
    end
  end

  def notification_agent_process_exists?(agent_notifications_id) do
    case Horde.Registry.lookup(__MODULE__, agent_notifications_id) do
      [] -> false
      _ -> true
    end
  end

  def agent_notifications_ids do
    Notifications.DynamicSupervisor.which_children
    |> Enum.map(fn {_, agent_notifications_proc_pid, _, _} ->
      Horde.Registry.keys(__MODULE__, agent_notifications_proc_pid)
      |> List.first
    end)
    |> Enum.sort
  end

end
