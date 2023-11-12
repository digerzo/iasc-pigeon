defmodule User do
  defstruct id: nil

  def new(id) do
    %User{id: id}
  end
end
