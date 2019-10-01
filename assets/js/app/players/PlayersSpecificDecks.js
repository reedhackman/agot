import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const PlayersSpecificDecks = props => {
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
  let decks = [];
  for (let faction in props.decks) {
    for (let agenda in props.decks[faction]) {
      if (faction !== "null" && agenda !== "null") {
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
  if (!expanded) {
    for (var i = 0; i < Math.min(5, decks.length); i++) {
      rows.push(
        <tr key={decks[i].faction + decks[i].agenda}>
          <td>
            <div className="PlayersSpecificDecks-Faction">
              <A href={`/decks/${decks[i].faction}`}>{decks[i].faction}</A>
            </div>
          </td>
          <td>
            <div className="PlayersSpecificDecks-Agenda">
              <A href={`/decks/${decks[i].faction}/${decks[i].agenda}`}>
                {decks[i].agenda}
              </A>
            </div>
          </td>
          <td>
            <div className="PlayersSpecificDecks-Percent">
              {Math.round(1000 * decks[i].percent) / 10}
            </div>
          </td>
          <td>
            <div className="PlayersSpecificDecks-Played">{decks[i].played}</div>
          </td>
        </tr>
      );
    }
  } else {
    decks.forEach(deck => {
      if (deck.faction && deck.agenda) {
        rows.push(
          <tr key={deck.faction + deck.agenda}>
            <td>
              <div className="PlayersSpecificDecks-Faction">
                <A href={`/decks/${deck.faction}`}>{deck.faction}</A>
              </div>
            </td>
            <td>
              <div className="PlayersSpecificDecks-Agenda">
                <A href={`/decks/${deck.faction}/${deck.agenda}`}>
                  {deck.agenda}
                </A>
              </div>
            </td>
            <td>
              <div className="PlayersSpecificDecks-Percent">
                {Math.round(1000 * deck.percent) / 10}
              </div>
            </td>
            <td>
              <div className="PlayersSpecificDecks-Played">{deck.played}</div>
            </td>
          </tr>
        );
      }
    });
  }
  return (
    <div>
      <h2>Decks</h2>
      <table>
        <thead>
          <tr>
            <th
              className="PlayersSpecificDecks-FactionHeader"
              onClick={() => handleSort("faction")}
            >
              <div className="PlayersSpecificDecks-Faction">Faction</div>
            </th>
            <th
              className="PlayersSpecificDecks-AgendaHeader"
              onClick={() => handleSort("agenda")}
            >
              <div className="PlayersSpecificDecks-Agenda">Agenda</div>
            </th>
            <th
              className="PlayersSpecificDecks-PercentHeader"
              onClick={() => handleSort("percent")}
            >
              <div className="PlayersSpecificDecks-Percent">Percent</div>
            </th>
            <th
              className="PlayersSpecificDecks-PercentHeader"
              onClick={() => handleSort("played")}
            >
              <div className="PlayersSpecificDecks-Played">Played</div>
            </th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
      <div onClick={() => setExpanded(!expanded)}>
        {decks.length >= 5 ? (
          <div>{expanded ? "collapse" : "expand"}</div>
        ) : null}
      </div>
    </div>
  );
};

export default PlayersSpecificDecks;
