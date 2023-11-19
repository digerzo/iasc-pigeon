defmodule Message do
  defstruct [:id, :text, :sender, :receiver, :timestamp, :secure, :expiration_time]

  def new(text, sender, receiver, secure \\ false, expiration_time \\ 20000) do
    id = App.Utils.generate_id() #:os.system_time(:millisecond)
    timestamp = :os.system_time(:millisecond)
    # new_expiration_time = timestamp + expiration_time

    %Message{
      id: id,
      text: text,
      sender: sender,
      receiver: receiver,
      timestamp: timestamp,
      secure: secure,
      expiration_time: expiration_time
    }
  end

  def update_text(message, new_text) do
    %Message{message | text: new_text}
  end

end
