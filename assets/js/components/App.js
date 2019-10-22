import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Home from "./Home.js";
import Decks from "./Decks.js";
import Players from "./Players.js";
import NavBar from "./NavBar.js";
import PlayersContextProvider from "../contexts/PlayersContext.js";
import DecksContextProvider from "../contexts/DecksContext.js";

const App = () => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "*": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return (
    <div className="App-wrapper">
      <NavBar />
      <PlayersContextProvider>
        <DecksContextProvider>{routeResult}</DecksContextProvider>
      </PlayersContextProvider>
    </div>
  );
};

export default App;
