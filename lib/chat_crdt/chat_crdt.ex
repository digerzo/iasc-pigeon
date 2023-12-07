defmodule Chats.Crdt do

  def start_link(_) do
    response = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap, name: Node.self(), sync_interval: 10)
    Chats.Crdt.refresh_neighbours()
    response
  end

  def set_neighbours(crdt, neighbours) do
    DeltaCrdt.set_neighbours(crdt, neighbours)
  end

  def refresh_neighbours() do
    neighbours = Node.list() |> Enum.map(fn n -> {n, n} end)

    Chats.Crdt.set_neighbours(Node.self(), neighbours)
  end

  def get_state(key) do
    DeltaCrdt.get(Node.self(), key)
  end

  def save_state(key, value) do
    Chats.Crdt.save_state(Node.self(), key, value)
  end

  def save_state(crdt, key, value) do
    DeltaCrdt.put(crdt, key, value)
  end

  def delete_state(key) do
    Chats.Crdt.delete_state(Node.self(), key)
  end

  def delete_state(crdt, key) do
    DeltaCrdt.delete(crdt, key)
  end
end
