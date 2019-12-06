defmodule Agot.Tjp.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: AgotTjpCache)
  end

  def init(state) do
    :ets.new(:excluded_cache, [:set, :public, :named_table])
    :ets.new(:tournament_cache, [:set, :public, :named_table])
    {:ok, state}
  end

  def get_excluded(key) do
    GenServer.call(AgotTjpCache, {:get, key, :excluded_cache})
  end

  def put_excluded(key, data) do
    GenServer.cast(AgotTjpCache, {:put, key, data, :excluded_cache})
  end

  def get_tournament(key) do
    GenServer.call(AgotTjpCache, {:get, key, :tournament_cache})
  end

  def put_tournament(key, data) do
    GenServer.cast(AgotTjpCache, {:put, key, data, :tournament_cache})
  end

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
