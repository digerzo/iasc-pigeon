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
    # @TODO: debe hacer la limpieza a cada momento?
    # Cada 3000 milisegundos intenta limpiar mensajes
    Process.send_after(self(), :cleanup, 3000)

    # # TODO: revisar como manejar correctamente este tema
    # # Obtengo procesos linkeados
    # { _ , links } = Process.info(self(), :links)
    # # Logger.info("Links: #{inspect(links)}")

    # # Obtengo el pid del unico proceso linkeado
    # chat_pid = hd(links)

    # # Obtengo mensajes del proceso tipo Chat linkeado
    # messages = Chat.get_messages(chat_pid)
    # # Logger.info("Messages: #{inspect(messages)}")

    # # Filtro mensajes expirados a traves del timestamp y si tienen activada la flag secure
    # messages_filtered = filter_messages(messages)
    # # Logger.info("Messages Filtered: #{inspect(messages_filtered)}")

    # # Obtengo keys (mensajes ids) de los mensajes expirados
    # messages_filtered_ids = Enum.map(messages_filtered, fn {key, _message} -> key end)

    # # Le indico al proceso linkeado que elimine los mensajes que filtre
    # Chat.delete_messages(chat_pid, messages_filtered_ids)

    {:noreply, state}
  end

  def filter_messages(messages) do
    timestamp = :os.system_time(:millisecond)
    Enum.filter(messages, fn {_key, message} ->
      case message do
        %Message{secure: true, expiration_time: expiration_time} when expiration_time < timestamp ->
          true
        _ ->
          false
      end
    end)
  end

end
