import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Faction from "./DecksFaction";
import Agenda from "./DecksAgenda";
import Table from "./DecksTable";
const moment = require("moment");

const Decks = props => {
  const [games, setGames] = useState([]);
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
  const [min, setMin] = useState(20);

  useEffect(() => {
    async function fetchData() {
      const response = await fetch(`/api/games/${start}/${end}`);
      const data = await response.json();
      setGames(data.games);
    }
    fetchData();
  }, [start, end]);

  const routes = {
    "/decks": () => <Table min={min} games={games} />,
    "/decks/:faction": ({ faction }) => (
      <Faction
        min={min}
        games={games}
        faction={faction.replace(/%20/g, " ").replace(/%22/g, '"')}
      />
    ),
    "/decks/:faction/:agenda": ({ faction, agenda }) => (
      <Agenda
        min={min}
        games={games}
        faction={faction.replace(/%20/g, " ").replace(/%22/g, '"')}
        agenda={agenda.replace(/%20/g, " ").replace(/%22/g, '"')}
      />
    )
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
      <input type="number" value={min} onChange={e => setMin(e.target.value)} />
      {routeResult}
    </div>
  );
};

export default Decks;
