import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Table = props => {
  const [sortBy, setSortBy] = useState("percent");
  const [asc, setAsc] = useState(false);
  const handleSort = e => {
    if (sortBy === e) {
      setAsc(!asc);
    } else {
      setSortBy(e);
      setAsc(false);
    }
  };
  let decks = {};
  props.games.forEach(game => {
    if (!decks[game.winner_faction]) {
      decks[game.winner_faction] = {
        [game.winner_agenda]: {
          wins: 1,
          losses: 0
        }
      };
    } else if (!decks[game.winner_faction][game.winner_agenda]) {
      decks[game.winner_faction][game.winner_agenda] = {
        wins: 1,
        losses: 0
      };
    } else {
      decks[game.winner_faction][game.winner_agenda].wins++;
    }
    if (!decks[game.loser_faction]) {
      decks[game.loser_faction] = {
        [game.loser_agenda]: {
          wins: 0,
          losses: 1
        }
      };
    } else if (!decks[game.loser_faction][game.loser_agenda]) {
      decks[game.loser_faction][game.loser_agenda] = {
        wins: 0,
        losses: 1
      };
    } else {
      decks[game.loser_faction][game.loser_agenda].losses++;
    }
  });
  let list = [];
  for (let faction in decks) {
    for (let agenda in decks[faction]) {
      if (
        decks[faction][agenda].wins + decks[faction][agenda].losses >=
        props.min
      ) {
        list.push({
          faction: faction,
          agenda: agenda,
          percent:
            decks[faction][agenda].wins /
            (decks[faction][agenda].wins + decks[faction][agenda].losses),
          played: decks[faction][agenda].losses + decks[faction][agenda].wins
        });
      }
    }
  }
  list.sort((a, b) => {
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
  list.forEach(deck => {
    rows.push(
      <tr key={deck.faction + deck.agenda}>
        <td>
          <A href={`/decks/${deck.faction}`}>{deck.faction}</A>
        </td>
        <td>
          <A href={`/decks/${deck.faction}/${deck.agenda}`}>{deck.agenda}</A>
        </td>
        <td>{deck.percent}</td>
        <td>{deck.played}</td>
      </tr>
    );
  });
  return (
    <div>
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
    </div>
  );
};

export default Table;
