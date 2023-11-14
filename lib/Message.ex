defmodule Message do
  defstruct id: nil, text: "", sender: nil, receiver: nil, timestamp: nil

  def new(text, sender, receiver) do
    #TODO: verificar como generar IDs únicos
    id = :erlang.system_time(:millisecond)
    %Message{id: id, text: text, sender: sender, receiver: receiver, timestamp: :os.system_time(:millisecond)}
  end
end
