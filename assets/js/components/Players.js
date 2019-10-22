import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Table from "./players/Table.js";
import Specific from "./players/Specific.js";

const Players = props => {
  const [players, setPlayers] = useState([]);
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/players/all");
      const data = await response.json();
      setPlayers(data.players);
    }
    fetchData();
  }, []);
  const routes = {
    "/:id": ({ id }) => <Specific id={id} />,
    "*": () => <Table players={players} />
  };
  const routeResult = useRoutes(routes);
  return <div className="Players-wrapper">{routeResult}</div>;
};

export default Players;
