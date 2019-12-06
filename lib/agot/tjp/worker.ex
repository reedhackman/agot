defmodule Agot.Tjp.Worker do
  use GenServer

  alias Agot.Tjp.Broker

  @minute 1000 * 60

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Process.send_after(self(), :work, @minute)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Broker.check_all_incomplete_games()
    Broker.check_for_new_games()
    Process.send_after(self(), :work, 10 * @minute)
    IO.inspect(DateTime.utc_now())
    {:noreply, state}
  end
end
