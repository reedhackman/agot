import React, { useState, useEffect, createContext, Component } from "react";

export const DeckContext = createContext();

const DeckContextProvider = props => {
  const [state, setState] = useState({});
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/decks");
      const data = await response.json();
      setState(data);
    }
    fetchData();
  }, []);

  return (
    <DeckContext.Provider value={{ ...state }}>
      {props.children}
    </DeckContext.Provider>
  );
};

export default DeckContextProvider;
