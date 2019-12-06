defmodule Agot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      worker(Agot.Repo, []),
      # Start the endpoint when the application starts
      supervisor(AgotWeb.Endpoint, [])
      # Starts a worker by calling: Agot.Worker.start_link(arg)
      # {Agot.Worker, arg},
      # worker(Agot.Tjp.Cache, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Agot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AgotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
