import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Opponents = props => {
  const [sortBy, setSortBy] = useState("played");
  const [asc, setAsc] = useState(false);
  const [expanded, setExpanded] = useState(false);
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
        Math.round(
          (1000 * props.opponents[opponent].wins) /
            (props.opponents[opponent].wins + props.opponents[opponent].losses)
        ) / 10,
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
  if (!expanded) {
    for (var i = 0; i < Math.min(5, opponents.length); i++) {
      rows.push(
        <tr key={opponents[i].id}>
          <td>
            <div className="PlayersSpecificOpponents-Name">
              <A href={`/players/${opponents[i].id}`}>{opponents[i].name}</A>
            </div>
          </td>
          <td>
            <div className="PlayersSpecificOpponents-Number">
              {opponents[i].played}
            </div>
          </td>
          <td>
            <div className="PlayersSpecificOpponents-Number">
              {opponents[i].percent}
            </div>
          </td>
        </tr>
      );
    }
  } else {
    opponents.forEach(opponent => {
      rows.push(
        <tr key={opponent.id}>
          <td>
            <div className="PlayersSpecificOpponents-Name">
              <A href={`/players/${opponent.id}`}>{opponent.name}</A>
            </div>
          </td>
          <td>
            <div className="PlayersSpecificOpponents-Number">
              {opponent.played}
            </div>
          </td>
          <td>
            <div className="PlayersSpecificOpponents-Number">
              {opponent.percent}
            </div>
          </td>
        </tr>
      );
    });
  }

  return (
    <div>
      <h2>Opponents</h2>
      <table>
        <thead>
          <tr>
            <th
              className="PlayersSpecificOpponents-NameHeader"
              onClick={() => handleSort("name")}
            >
              <div className="PlayersSpecificOpponents-Name">Name</div>
            </th>
            <th
              className="PlayersSpecificOpponents-NumberHeader"
              onClick={() => handleSort("played")}
            >
              <div className="PlayersSpecificOpponents-Number">Played</div>
            </th>
            <th
              className="PlayersSpecificOpponents-NumberHeader"
              onClick={() => handleSort("percent")}
            >
              <div className="PlayersSpecificOpponents-Number">Percent</div>
            </th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
      <div onClick={() => setExpanded(!expanded)}>
        {opponents.length >= 5 ? (
          <div>{expanded ? "collapse" : "expand"}</div>
        ) : null}
      </div>
    </div>
  );
};

export default Opponents;
