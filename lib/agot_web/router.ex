defmodule AgotWeb.Router do
  use AgotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", AgotWeb do
  #   pipe_through :api
  # end
  scope "/api", AgotWeb do
    pipe_through :api

    get "/players/all", PlayersApiController, :all
    get "/players/specific/:id", PlayersApiController, :specific
  end

  scope "/", AgotWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
