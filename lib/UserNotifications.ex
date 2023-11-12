defmodule UserNotifications do
  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: {:local, {:via, :user_notifications, user_id}})
  end

  def init(user_id) do
    {:ok, %{}}
  end

  def send_notification(user_id, message) do
    GenServer.cast({:via, :user_notifications, user_id}, {:send_notification, message})
  end

  def get_notifications(user_id) do
    GenServer.call({:via, :user_notifications, user_id}, :get_notifications)
  end

  def handle_cast({:send_notification, message}, state) do
    updated_notifications = [message | state]
    {:noreply, updated_notifications}
  end

  def handle_call(:get_notifications, _from, state) do
    {:reply, state, state}
  end
end
