defmodule Pigeon.NodeObserver do
  use GenServer
  require Logger

  # alias CustomIASC.{HordeRegistry, HordeSupervisor}

  def start_link(_)do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl GenServer
  def init(state) do
    # https://erlang.org/doc/man/net_kernel.html#monitor_nodes-1
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, state}
  end

  @impl GenServer
  @doc """
  Handler that will be called when a node has left the cluster.
  """
  def handle_info({:nodedown, node, _node_type}, state) do
    Logger.info("---- Node down: #{node} ----")

    refresh_members()

    {:noreply, state}
  end

  @impl GenServer
  @doc """
  Handler that will be called when a node has joined the cluster.
  """
  def handle_info({:nodeup, node, _node_type}, state) do
    Logger.info("---- Node up: #{node} ----")
    refresh_members()
    {:noreply, state}
  end

  defp refresh_members() do
        # supervisors
        set_members(Chats.ChatDynamicSupervisor)
        set_members(Notifications.NotificationsDynamicSupervisor)

        # registries
        set_members(Chats.Registry)
        set_members(Notifications.NotificationsRegistry)
  end

  defp set_members(name) do
    members = Enum.map([Node.self() | Node.list()], &{name, &1})

    :ok = Horde.Cluster.set_members(name, members)
  end
end
