defmodule Message do
  defstruct [:id, :text, :sender, :receiver, :timestamp, :secure, :expiration_time]

  def new(text, sender, receiver, secure \\ false, expiration_time \\ 20000) do
    id = :os.system_time(:millisecond)
    timestamp = :os.system_time(:millisecond)
    new_expiration_time = timestamp + expiration_time

    %Message{
      id: id,
      text: text,
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      secure: secure,
      expiration_time: new_expiration_time
    }
  end

end
