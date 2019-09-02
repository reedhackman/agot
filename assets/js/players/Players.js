import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Specific from "./Specific";
import Table from "./Table";

const Players = props => {
  const [players, setPlayers] = useState([]);
  const [page, setPage] = useState(0);
  const [last, setLast] = useState(0);
  const [sortBy, setSortBy] = useState("name");
  const [asc, setAsc] = useState(false);
  const [input, setInput] = useState("");
  const [min, setMin] = useState(20);
  useEffect(() => {
    async function fetchData() {
      const response = await fetch("/api/players");
      const data = await response.json();
      let count = 0;
      data.forEach(player => {
        if (player.played >= min) {
          count++;
        }
      });
      setPage(Math.min(1, count));
      setLast(Math.ceil(count / 20));
      setPlayers(data);
    }
    fetchData();
  }, []);
  const handleMin = newMin => {
    if (min !== newMin) {
      let count = 0;
      players.forEach(player => {
        if (
          player.played >= newMin &&
          player.name.toLowerCase().indexOf(input.toLowerCase()) !== -1
        ) {
          count++;
        }
      });
      setPage(Math.min(1, count));
      setLast(Math.ceil(count / 20));
      setMin(newMin);
    }
  };
  const handleSort = newSort => {
    if (newSort === sortBy) {
      setAsc(!asc);
    } else {
      setAsc(false);
      setSortBy(newSort);
    }
  };
  const handlePage = newPage => {
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    setPage(newPage);
  };
  const handleSearch = newInput => {
    if (input !== newInput) {
      let count = 0;
      players.forEach(player => {
        if (
          player.name.toLowerCase().indexOf(newInput.toLowerCase()) !== -1 &&
          player.played >= min
        ) {
          count++;
        }
      });
      setPage(Math.min(1, count));
      setLast(Math.ceil(count / 20));
      setInput(newInput);
    }
  };
  const routes = {
    "/players": () => (
      <Table
        state={{
          players: players,
          page: page,
          last: last,
          sortBy: sortBy,
          input: input,
          min: min,
          asc: asc
        }}
        handleSearch={handleSearch}
        handlePage={handlePage}
        handleMin={handleMin}
        handleSort={handleSort}
      />
    ),
    "/players/:id": ({ id }) => (
      <Specific
        player={players.find(p => {
          return p.id == parseInt(id);
        })}
      />
    )
  };

  const routeResult = useRoutes(routes);
  return <div>{routeResult}</div>;
};

export default Players;
