import React, { useState, useContext } from "react";
import { useRoutes } from "hookrouter";
import Table from "./players/Table.js";
import Specific from "./players/Specific.js";
import { PlayersContext } from "../contexts/PlayersContext.js";

const Players = props => {
  const { players } = useContext(PlayersContext);

  const routes = {
    "/:id": ({ id }) => <Specific id={id} />,
    "*": () => <Table players={players} />
  };
  const routeResult = useRoutes(routes);
  return <div className="Players-wrapper">{routeResult}</div>;
};

export default Players;
