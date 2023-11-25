defmodule Notification do

  use Task

  def send_notification(chat_pid, message) do
    notification = "Tienes un mensaje nuevo de #{message.sender}: #{message.body}"
    Chat.new_message(chat_pid, notification)
  end

end
