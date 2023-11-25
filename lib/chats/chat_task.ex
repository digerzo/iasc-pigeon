defmodule Chats.Task do
  use Task

  def start_link do
    Task.start_link(__MODULE__, :my_task, [])
  end

  def add_message(_agent_pid, _message) do

  end


end
