defmodule Init do
  require Logger

    @doc """
  Caso de Prueba: Flujo de mensajes (enviar, leer, modificar, eliminar)

  {:ok, [pid_lauti, pid_agus, pid_walter]} = Init.init_users()
  Init.lauti_send_message_to_agus(pid_lauti)
  Init.lauti_read_his_messages_with_agus(pid_lauti)
  Init.lauti_modify_message_with_agus(pid_lauti)
  Init.lauti_delete_message_with_agus(pid_lauti)
  Init.agus_receive_notification_from_lauti(pid_agus)
  Init.lauti_send_many_messages_to_agus(pid_lauti)
  Init.lauti_delete_many_messages_with_agus(pid_lauti)

  """

  def init_users() do
    Logger.info("Se crean las sesiones de los usuarios")

    {:ok, pid_lauti} = User.log_in("lauti")
    {:ok, pid_agus} = User.log_in("agus")
    {:ok, pid_walter} = User.log_in("walter")

    {:ok, [pid_lauti, pid_agus, pid_walter]}
  end

  def lauti_send_message_to_agus(pid_lauti) do

    message = Message.new("Hola, que tal?", "lauti", "agus")
    User.send_message(pid_lauti, message)
  end

  def lauti_read_his_messages_with_agus(pid_lauti) do
    User.read_messages(pid_lauti, "agus")
  end

  def lauti_modify_message_with_agus(pid_lauti) do
    Logger.info("Lauti modifica su mensaje con Agus")

    new_text = "Todo bien?"
    map = lauti_read_his_messages_with_agus(pid_lauti)
    message_id = Map.keys(map) |> List.first()
    User.modify_message(pid_lauti, message_id, new_text, "agus")
    lauti_read_his_messages_with_agus(pid_lauti)
  end

  def lauti_delete_message_with_agus(pid_lauti) do
    Logger.info("Lauti elimina su mensaje con Agus")

    map = lauti_read_his_messages_with_agus(pid_lauti)
    message_id = Map.keys(map) |> List.first()
    User.delete_message(pid_lauti, message_id, "agus")
    lauti_read_his_messages_with_agus(pid_lauti)
  end

  def agus_receive_notification_from_lauti(pid_agus) do
    Logger.info("Agus recibe una notificacion de Lauti")

    User.read_notifications(pid_agus)
  end

  def lauti_send_many_messages_to_agus(pid_lauti) do
    Logger.info("Lauti le envia tres mensajes a Agus")

    lauti_send_message_to_agus(pid_lauti)
    lauti_send_message_to_agus(pid_lauti)
    lauti_send_message_to_agus(pid_lauti)
    lauti_read_his_messages_with_agus(pid_lauti)
  end

  def lauti_delete_two_messages_with_agus(pid_lauti) do
    Logger.info("Lauti elimina dos mensajes con Agus")

    map = lauti_read_his_messages_with_agus(pid_lauti)
    keys = Map.keys(map)
    messages_ids = Enum.take(keys, 2)
    User.delete_messages(pid_lauti, messages_ids, "agus")
    lauti_read_his_messages_with_agus(pid_lauti)
  end
end
