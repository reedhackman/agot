import React from "react";
import { PlayerContext } from "../contexts/PlayerContext";
import { useRoutes } from "hookrouter";
import TableWrapper from "./players/TableWrapper";

const Players = () => {
  const routes = {
    "/": () => players => {
      return <TableWrapper players={players} />;
    }
  };

  const routeResult = useRoutes(routes);
  return (
    <PlayerContext.Consumer>
      {playerContext => {
        const players = Object.values(playerContext);
        return routeResult(players);
      }}
    </PlayerContext.Consumer>
  );
};

export default Players;
