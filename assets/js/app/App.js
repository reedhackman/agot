import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import GameContextProvider from "./contexts/GameContext";
import DeckContextProvider from "./contexts/DeckContext";
import PlayerContextProvider from "./contexts/PlayerContext";
import Home from "./components/Home.js";
import FAQ from "./components/FAQ.js";
import Decks from "./components/decks/Decks.js";
import Players from "./components/players/Players.js";

const App = props => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "/faq": () => <FAQ />,
    "*": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return (
    <div className="App">
      <GameContextProvider>
        <PlayerContextProvider>
          <DeckContextProvider>{routeResult}</DeckContextProvider>
        </PlayerContextProvider>
      </GameContextProvider>
    </div>
  );
};
