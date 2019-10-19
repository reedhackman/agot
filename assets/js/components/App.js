import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Home from "./Home.js";
import Decks from "./Decks.js";
import Players from "./Players.js";

const App = props => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "*": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return <div className="App">{routeResult}</div>;
};

export default App;
