import React from "react";
import { useRoutes } from "hookrouter";
import Home from "./components/Home.js";
import Decks from "./components/decks/Decks.js";
import Players from "./components/players/Players.js";

const App = () => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "*": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return (
    <div className="App">
      {routeResult}
    </div>
  );
};

export default App
