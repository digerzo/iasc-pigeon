defmodule Notifications.NotificationsTask do
  def start_link(sender_user_id, reciver_user_id) do
    Task.start_link(__MODULE__, :notify, [sender_user_id, reciver_user_id])
  end

  def notify(sender_user_id, reciver_user_id) do
    notification = "Tienes una notificación de #{sender_user_id}"
    {:ok, notification_agent_pid} = Notifications.NotificationsRegistry.find_or_create(reciver_user_id)
    Notifications.add_notification(notification_agent_pid, notification)
    {:ok}
  end
end
