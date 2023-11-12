defmodule Message do
  defstruct id: nil, text: "", sender: nil, receiver: nil, timestamp: nil

  def new(id, text, sender, receiver) do
    %Message{id: id, text: text, sender: sender, receiver: receiver, timestamp: :os.system_time(:millisecond)}
  end
end
