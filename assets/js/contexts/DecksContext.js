import React, { useState, useEffect, createContext } from "react";

export const DecksContext = createContext();

const DecksContextProvider = props => {
  const [state, setState] = useState(false);
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/decks");
      const data = await response.json();
      console.log(data);
      setState(data);
    }
    fetchData();
  }, []);

  return (
    <DecksContext.Provider value={{ ...state }}>
      {props.children}
    </DecksContext.Provider>
  );
};

export default DecksContextProvider;
