import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Faction from "./Faction";
import Agenda from "./Agenda";
import Table from "./Table";
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
      <Faction min={min} games={games} faction={faction} />
    ),
    "/decks/:faction/:agenda": ({ faction, agenda }) => (
      <Agenda min={min} games={games} faction={faction} agenda={agenda} />
    )
  };
  console.log(games);
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
