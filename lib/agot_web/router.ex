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

  scope "/", AgotWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/players/*path", PlayersController, :index
    get "/decks/*path", DecksController, :index
    get "/faq", PageController, :faq
  end

  # Other scopes may use custom stacks.
  # scope "/api", AgotWeb do
  #   pipe_through :api
  # end
  scope "/api", AgotWeb do
    pipe_through :api

    get "/players", ApiController, :all_players
    get "/players/:id", ApiController, :specific_player
    get "/games", ApiController, :all_games
    get "/games/page/:page", ApiController, :games_by_page
    get "/games/date/:start/:end", ApiController, :games_over_range
    get "/decks/:faction/:agenda", ApiController, :games_for_deck
  end
end
