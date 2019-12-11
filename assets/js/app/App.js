import React from "react";
import { useRoutes } from "hookrouter";
import Home from "./components/Home";
import Decks from "./components/Decks";
import Players from "./components/Players";
import NavBar from "./components/NavBar";
import PlayerContextProvider from "./contexts/PlayerContext";

const App = () => {
  const routes = {
    "/players*": () => <Players />,
    "/decks*": () => <Decks />,
    "": () => <Home />
  };
  const routeResult = useRoutes(routes);
  return (
    <div className="App">
      <NavBar />
      <PlayerContextProvider>{routeResult}</PlayerContextProvider>
    </div>
  );
};

export default App;
