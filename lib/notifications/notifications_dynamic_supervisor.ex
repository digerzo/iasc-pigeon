defmodule Notifications.NotificationsDynamicSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def which_children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Notifications.NotificationsDynamicSupervisor.start_child(:algo)
  def start_child(name) do
    spec = %{
      id: Notifications,
      start: {Notifications, :start_link, [%{},name]}
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
