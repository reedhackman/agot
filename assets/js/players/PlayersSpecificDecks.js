import React, { useState, useEffect } from "react";

const Decks = props => {
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
  let decks = [];
  for (let faction in props.decks) {
    for (let agenda in props.decks[faction]) {
      decks.push({
        faction: faction,
        agenda: agenda,
        percent:
          props.decks[faction][agenda].wins /
          (props.decks[faction][agenda].wins +
            props.decks[faction][agenda].losses),
        played:
          props.decks[faction][agenda].wins +
          props.decks[faction][agenda].losses
      });
    }
  }
  decks.sort((a, b) => {
    if (sortBy === "faction" || sortBy === "agenda") {
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
  decks.forEach(deck => {
    rows.push(
      <tr key={deck.faction + deck.agenda}>
        <td>{deck.faction}</td>
        <td>{deck.agenda}</td>
        <td>{deck.percent}</td>
        <td>{deck.played}</td>
      </tr>
    );
  });
  return (
    <div>
      <h2 onClick={() => setShowing(!showing)}>Decks</h2>
      {showing ? (
        <table>
          <thead>
            <tr>
              <th onClick={() => handleSort("faction")}>Faction</th>
              <th onClick={() => handleSort("agenda")}>Agenda</th>
              <th onClick={() => handleSort("percent")}>Percent</th>
              <th onClick={() => handleSort("played")}>Played</th>
            </tr>
          </thead>
          <tbody>{rows}</tbody>
        </table>
      ) : null}
    </div>
  );
};

export default Decks;
