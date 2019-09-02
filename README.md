# Agot

The final version of my ELO and deck tracking project for games on thejoustingpavilion.com, an extremely awesome website that makes running tournaments for the A Game of Thrones LCG 2nd edition much easier and allows plebs to follow along with the competitive scene. This project uses Phoenix, an Elixir framework, to run the backend and a (currently in development) single-page React app for the frontend. A link to the site will be posted once I launch, but if you want to see what this project is all about before then, feel free to clone this repo and get it running using the steps listed below. Also worth noting, the initial database seeding will take up to an hour and will require an active internet connection (it will start as soon as you run "mix phx.server").

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`
