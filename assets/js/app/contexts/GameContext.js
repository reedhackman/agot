import React, { useState, useEffect, createContext, Component } from "react";

export const GameContext = createContext();

const GameContextProvider = props => {
  const [state, setState] = useState({});

  const addGames = games => {
    setState({ games: [...state.games, ...games] });
  };
  return (
    <GameContext.Provider value={{ ...state, addGames: addGames }}>
      {props.children}
    </GameContext.Provider>
  );
};

export default GameContextProvider;
