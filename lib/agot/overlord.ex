defmodule Agot.Overlord do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Agot.Cache, []),
      worker(Agot.Tjp, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
