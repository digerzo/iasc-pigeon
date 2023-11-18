defmodule Chats.RegistrySupervisorWrapper do

  @registry_name :chat_registry_name

  def find_or_create_process(chat_id) do
    if account_process_exists?(chat_id) do
      # Registry.lookup(:account_main_registry, chat_id)
      {:ok, Registry.lookup(@registry_name, chat_id) |> List.first |> elem(0) }
    else
      Chats.ChatDynamicSupervisor.start_child
    end
  end

  def account_process_exists?(chat_id) do
    case Registry.lookup(@registry_name, chat_id) do
      [] -> false
      _ -> true
    end
  end

  @spec chat_ids() :: list()
  def chat_ids do
    Chats.ChatDynamicSupervisor.which_children
    |> Enum.map(fn {_, account_proc_pid, _, _} ->
      Registry.keys(@registry_name, account_proc_pid)
      |> List.first
    end)
    |> Enum.sort
  end

end

#Chats.RegistrySupervisorWrapper.find_or_create_process("becb8b242d")
#Chats.RegistrySupervisorWrapper.find_or_create_process(2)
#Chats.RegistrySupervisorWrapper.find_or_create_process(3)
#{ok, pid} = Chats.RegistrySupervisorWrapper.find_or_create_process(1)
