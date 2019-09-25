defmodule Agot.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: AgotCache)
  end

  def init(state) do
    :ets.new(:exclude_cache, [:set, :public, :named_table])
    :ets.new(:tournaments_cache, [:set, :public, :named_table])
    {:ok, state}
  end

  # EXCLUDE
  def get_exclude(key) do
    GenServer.call(AgotCache, {:get, key, :exclude_cache})
  end

  def put_exclude(key, data) do
    GenServer.cast(AgotCache, {:put, key, data, :exclude_cache})
  end

  # TOURNAMENTS
  def get_tournament(key) do
    GenServer.call(AgotCache, {:get, key, :tournaments_cache})
  end

  def put_tournament(key, data) do
    GenServer.cast(AgotCache, {:put, key, data, :tournaments_cache})
  end

  # HANDLERS
  def handle_call({:get, key, table}, _from, state) do
    reply =
      case :ets.lookup(table, key) do
        [] -> nil
        [{_key, data}] -> data
      end

    {:reply, reply, state}
  end

  def handle_cast({:put, key, data, table}, state) do
    case :ets.lookup(table, key) do
      [] -> :ets.insert(table, {key, data})
      [{_key, _data}] -> nil
    end

    {:noreply, state}
  end

  def handle_cast({:delete, key, table}, state) do
    :ets.delete(table, key)
    {:noreply, state}
  end
end
