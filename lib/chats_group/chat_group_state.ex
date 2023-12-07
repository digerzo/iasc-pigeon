defmodule ChatGroups.State do
  defstruct [:id, :messages, :participants, :admins]

  def new(id, owner) do
    %ChatGroups.State{id: id, messages: %{}, participants: [owner], admins: [owner]}
  end
end
