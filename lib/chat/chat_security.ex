defmodule ChatSecurity do
  defstruct secure: nil, time: nil

  def new(secure, time) do
    %ChatSecurity{secure: secure, time: time}
  end
end
