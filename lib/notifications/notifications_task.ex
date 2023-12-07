defmodule Notifications.Task do
  def start_link(sender, receiver_user_id) do
    Task.start_link(__MODULE__, :notify, [sender, receiver_user_id])
  end

  def notify(sender, receiver_user_id) do
    notification = "Tienes una notificación de #{sender}"
    {:ok, notification_agent_pid} = Notifications.Registry.find_or_create(receiver_user_id)
    Notifications.Agent.add_notification(notification_agent_pid, notification)
    {:ok}
  end
end
