import React, { useState, useEffect, createContext } from "react";

export const PlayersContext = createContext();

const PlayersContextProvider = props => {
  const [state, setState] = useState(false);
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/players");
      const data = await response.json();
      setState(data);
    }
    fetchData();
  }, []);

  return (
    <PlayersContext.Provider value={{ ...state }}>
      {props.children}
    </PlayersContext.Provider>
  );
};

export default PlayersContextProvider;
