import React, { useState, useEffect, createContext, Component } from "react";

export const PlayerContext = createContext();

const PlayerContextProvider = props => {
  const [state, setState] = useState([]);
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/players");
      console.log("fetched player data");
      const data = await response.json();
      setState(data);
    }
    fetchData();
  }, []);

  return (
    <PlayerContext.Provider value={{ ...state }}>
      {props.children}
    </PlayerContext.Provider>
  );
};

export default PlayerContextProvider;
