defmodule Chats.ChatAgent do
  use Agent

  def start_link(initial_state \\ %{}, name) do
    Agent.start_link(fn -> initial_state end, name: name)
  end

  def get_messages(agent_pid) do
    Agent.get(agent_pid, &Map.values/1)
  end

  def add_message(agent_pid, message) do
    Agent.update(agent_pid, fn state ->
      Map.put(state, message.id, message)
    end)
  end

  def modify_message(agent_pid, message_id, new_text) do
    Agent.update(agent_pid, fn state ->
      Map.update!(state, message_id, &update_message_text(&1, new_text))
    end)
  end

  defp update_message_text(message, new_text) do
    Map.put(message, :text, new_text)
  end

  def delete_message(agent_pid, message_id) do
    Agent.update(agent_pid, fn state ->
      Map.delete(state, message_id)
    end)
  end

  def delete_messages(agent_pid, message_ids) do
    Agent.update(agent_pid, fn state ->
      Enum.reduce(message_ids, state, fn message_id, acc_state ->
        Map.delete(acc_state, message_id)
      end)
    end)
  end


end
