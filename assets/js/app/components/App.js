import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Home from "./Home.js";
import FAQ from "./FAQ.js";
import Decks from "./decks/Decks.js";
import Players from "./players/Players.js";

const App = props => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "/faq": () => <FAQ />,
    "*": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return <div className="App">{routeResult}</div>;
};
