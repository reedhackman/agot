import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Faction from "./DecksFaction";
import Agenda from "./DecksAgenda";
import Table from "./DecksTable";
const moment = require("moment");

const Decks = props => {
  const useForceUpdate = () => useState()[1];
  const [allGames, setAllGames] = useState([]);
  const [start, setStart] = useState(
    moment()
      .utc()
      .subtract(90, "day")
      .format("YYYY-MM-DD")
  );
  const [end, setEnd] = useState(
    moment()
      .utc()
      .format("YYYY-MM-DD")
  );
  useEffect(() => {
    async function fetchData() {
      const response = await fetch(`/api/games/${start}/${end}`);
      const data = await response.json();
      setAllGames(data.games);
    }
    fetchData();
  }, [start, end]);

  const routes = {
    "/decks": () => <Table games={allGames} />,
    "/decks/:factionFull": ({ factionFull }) => {
      let faction = factionFull.replace(/%20/g, " ").replace(/%22/g, '"');
      let games = [];
      allGames.forEach(game => {
        if (game.winner_faction === faction || game.loser_faction === faction) {
          games.push(game);
        }
      });
      return <Faction games={games} faction={faction} />;
    },
    "/decks/:factionFull/:agendaFull": ({ factionFull, agendaFull }) => {
      let faction = factionFull.replace(/%20/g, " ").replace(/%22/g, '"');
      let agenda = agendaFull.replace(/%20/g, " ").replace(/%22/g, '"');
      let games = [];
      allGames.forEach(game => {
        if (
          (game.winner_faction === faction && game.winner_agenda === agenda) ||
          (game.loser_faction === faction && game.loser_agenda === agenda)
        ) {
          games.push(game);
        }
      });
      return <Agenda games={games} faction={faction} agenda={agenda} />;
    }
  };
  const routeResult = useRoutes(routes);
  return (
    <div>
      <div>
        <span>{"Start Date: "}</span>
        <input
          type="date"
          value={start}
          onChange={e => setStart(e.target.value)}
        />
      </div>
      <div>
        <span>{" End Date: "}</span>
        <input type="date" value={end} onChange={e => setEnd(e.target.value)} />
      </div>

      {routeResult}
    </div>
  );
};

export default Decks;
