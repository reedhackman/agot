import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Opponents = props => {
  const [sortBy, setSortBy] = useState("played");
  const [asc, setAsc] = useState(false);
  const [showing, setShowing] = useState(false);
  const handleSort = e => {
    if (sortBy === e) {
      setAsc(!asc);
    } else {
      setSortBy(e);
      setAsc(false);
    }
  };
  let opponents = [];
  for (let opponent in props.opponents) {
    opponents.push({
      id: opponent,
      name: props.opponents[opponent].name,
      percent:
        props.opponents[opponent].wins /
        (props.opponents[opponent].wins + props.opponents[opponent].losses),
      played: props.opponents[opponent].losses + props.opponents[opponent].wins,
      wins: props.opponents[opponent].wins,
      losses: props.opponents[opponent].losses
    });
  }
  opponents.sort((a, b) => {
    if (sortBy === "name") {
      if (b[sortBy] > a[sortBy]) {
        return !asc ? -1 : 1;
      } else if (b[sortBy] < a[sortBy]) {
        return !asc ? 1 : -1;
      } else {
        return 0;
      }
    } else {
      return !asc ? b[sortBy] - a[sortBy] : a[sortBy] - b[sortBy];
    }
  });
  let rows = [];
  opponents.forEach(opponent => {
    rows.push(
      <tr key={opponent.id}>
        <td>
          <A href={`/players/${opponent.id}`}>{opponent.name}</A>
        </td>
        <td>{opponent.played}</td>
        <td>{opponent.percent}</td>
      </tr>
    );
  });
  return (
    <div>
      <h2 onClick={() => setShowing(!showing)}>Opponents</h2>
      {showing ? (
        <table>
          <thead>
            <tr>
              <th onClick={() => handleSort("name")}>Name</th>
              <th onClick={() => handleSort("played")}>Played</th>
              <th onClick={() => handleSort("percent")}>Percent</th>
            </tr>
          </thead>
          <tbody>{rows}</tbody>
        </table>
      ) : null}
    </div>
  );
};

export default Opponents;
