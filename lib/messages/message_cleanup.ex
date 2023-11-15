defmodule MessageCleanup do
  use GenServer
  require Logger

  def start_link(state, name) do
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    # Programar la primera limpieza
    Process.send_after(self(), :cleanup, 0)
    {:ok, state}
  end

  ## Callbacks

  def handle_info(:cleanup, state) do
    Process.send_after(self(), :cleanup, 3000)

    { _ , links } = Process.info(self(), :links)
    # Logger.info("Links: #{inspect(links)}")

    chat_pid = hd(links)
    messages = Chat.get_messages(chat_pid)

    Logger.info("Messages: #{inspect(messages)}")

    {:noreply, state}
  end

end
