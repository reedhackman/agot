import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Table = props => {
  const [sortBy, setSortBy] = useState("percent");
  const [asc, setAsc] = useState(false);
  const [min, setMin] = useState(20);
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
    if (
      game.winner_faction === game.loser_faction &&
      game.winner_agenda === game.loser_agenda
    ) {
      if (!decks[game.winner_faction]) {
        decks[game.winner_faction] = {
          [game.winner_agenda]: {
            wins: 0,
            losses: 0,
            played: 2
          }
        };
      } else if (!decks[game.winner_faction][game.winner_agenda]) {
        decks[game.winner_faction][game.winner_agenda] = {
          wins: 0,
          losses: 0,
          played: 2
        };
      } else {
        decks[game.winner_faction][game.winner_agenda].played += 2;
      }
    } else {
      if (!decks[game.winner_faction]) {
        decks[game.winner_faction] = {
          [game.winner_agenda]: {
            wins: 1,
            losses: 0,
            played: 1
          }
        };
      } else if (!decks[game.winner_faction][game.winner_agenda]) {
        decks[game.winner_faction][game.winner_agenda] = {
          wins: 1,
          losses: 0,
          played: 1
        };
      } else {
        decks[game.winner_faction][game.winner_agenda].wins++;
        decks[game.winner_faction][game.winner_agenda].played++;
      }
      if (!decks[game.loser_faction]) {
        decks[game.loser_faction] = {
          [game.loser_agenda]: {
            wins: 0,
            losses: 1,
            played: 1
          }
        };
      } else if (!decks[game.loser_faction][game.loser_agenda]) {
        decks[game.loser_faction][game.loser_agenda] = {
          wins: 0,
          losses: 1,
          played: 1
        };
      } else {
        decks[game.loser_faction][game.loser_agenda].losses++;
        decks[game.loser_faction][game.loser_agenda].played++;
      }
    }
  });
  let list = [];
  for (let faction in decks) {
    for (let agenda in decks[faction]) {
      if (decks[faction][agenda].wins + decks[faction][agenda].losses >= min) {
        list.push({
          faction: faction,
          agenda: agenda,
          percent:
            Math.round(
              (1000 * decks[faction][agenda].wins) /
                (decks[faction][agenda].wins + decks[faction][agenda].losses)
            ) / 10,
          played: decks[faction][agenda].played
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
          <div className="DecksTable-Faction">
            <A href={`/decks/${deck.faction}`}>{deck.faction}</A>
          </div>
        </td>
        <td>
          <div className="DecksTable-Agenda">
            <A href={`/decks/${deck.faction}/${deck.agenda}`}>{deck.agenda}</A>
          </div>
        </td>
        <td>
          <div className="DecksTable-Number">{deck.percent}</div>
        </td>
        <td>
          <div className="DecksTable-Number">{deck.played}</div>
        </td>
      </tr>
    );
  });
  return (
    <div>
      <input type="number" value={min} onChange={e => setMin(e.target.value)} />
      <table>
        <thead>
          <tr>
            <th
              className="DecksTable-FactionHeader"
              onClick={() => handleSort("faction")}
            >
              <div className="DecksTable-Faction">Faction</div>
            </th>
            <th
              className="DecksTable-AgendaHeader"
              onClick={() => handleSort("agenda")}
            >
              <div className="DecksTable-Agenda">Agenda</div>
            </th>
            <th
              className="DecksTable-NumberHeader"
              onClick={() => handleSort("percent")}
            >
              <div className="DecksTable-Number">Win %</div>
            </th>
            <th
              className="DecksTable-NumberHeader"
              onClick={() => handleSort("played")}
            >
              <div className="DecksTable-Number"># Played</div>
            </th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </div>
  );
};

export default Table;
