defmodule Notifications do
  use Agent

  @notifications_registry_name Notifications.NotificationsRegistry

  def start_link(initial_state \\ %{}, name) do
    Agent.start_link(fn -> initial_state end, name: {:via, Horde.Registry, {@notifications_registry_name, name, "notification_agent_#{name}"}})
  end

  # Notifications.get_notifications(pid)
  def get_notifications(agent_notifications_pid) do
    Agent.get(agent_notifications_pid, & &1)
  end

  # Notifications.read_notifications(pid)
  def read_notifications(agent_notifications_pid) do
    notifications = get_notifications(agent_notifications_pid)
    delete_notifications(agent_notifications_pid)
    notifications
  end

  # Notifications.add_notification(pid, "Notificacion 1")
  def add_notification(agent_notifications_pid, notificacion) do
    Agent.update(agent_notifications_pid, fn state ->
      [notificacion | state]
    end)
  end

  # Notifications.delete_notifications(pid)
  def delete_notifications(agent_notifications_pid) do
    Agent.update(agent_notifications_pid, fn _state ->
      %{}
    end)
  end



end
