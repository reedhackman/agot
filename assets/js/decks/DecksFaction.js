import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Faction = props => {
  const [sortBy, setSortBy] = useState("percent");
  const [asc, setAsc] = useState(false);
  const [games, setGames] = useState([]);
  const handleSort = e => {
    if (sortBy === e) {
      setAsc(!asc);
    } else {
      setSortBy(e);
      setAsc(false);
    }
  };
  useEffect(() => {
    let gamesArray = [];
    props.games.forEach(game => {
      if (
        game.winner_faction === props.faction ||
        game.loser_faction === props.faction
      ) {
        gamesArray.push(game);
      }
    });
    setGames(gamesArray);
  }, [props]);
  let decksObject = {};
  games.forEach(game => {
    if (
      game.winner_faction === game.loser_faction &&
      game.winner_agenda === game.loser_agenda
    ) {
      if (!decksObject[game.winner_agenda]) {
        decksObject[game.winner_agenda] = {
          wins: 0,
          losses: 0,
          played: 1
        };
      } else {
        decksObject[game.winner_agenda].played++;
      }
    } else {
      if (game.winner_faction === props.faction) {
        if (!decksObject[game.winner_agenda]) {
          decksObject[game.winner_agenda] = {
            wins: 0,
            losses: 0,
            played: 0
          };
        }
        decksObject[game.winner_agenda].wins++;
        decksObject[game.winner_agenda].played++;
      }
      if (game.loser_faction === props.faction) {
        if (!decksObject[game.loser_agenda]) {
          decksObject[game.loser_agenda] = {
            wins: 0,
            losses: 0,
            played: 0
          };
        }
        decksObject[game.loser_agenda].losses++;
        decksObject[game.loser_agenda].played++;
      }
    }
  });
  let decks = [];
  for (let agenda in decksObject) {
    decks.push({
      agenda: agenda,
      percent:
        decksObject[agenda].wins /
        (decksObject[agenda].wins + decksObject[agenda].losses),
      played: decksObject[agenda].played
    });
  }
  decks.sort((a, b) => {
    if (asc) {
      if (sortBy === "agenda") {
        if (a[sortBy].toLowerCase() > b[sortBy].toLowerCase()) {
          return -1;
        } else if (b[sortBy].toLowerCase() > a[sortBy].toLowerCase()) {
          return 1;
        }
        return 0;
      }
      return a[sortBy] - b[sortBy];
    } else {
      if (sortBy === "agenda") {
        if (a[sortBy].toLowerCase() > b[sortBy].toLowerCase()) {
          return 1;
        } else if (b[sortBy].toLowerCase() > a[sortBy].toLowerCase()) {
          return -1;
        }
        return 0;
      }
      return b[sortBy] - a[sortBy];
    }
  });
  let rows = [];
  decks.forEach(deck => {
    rows.push(
      <tr key={deck.agenda}>
        <td>
          <div className="DecksFaction-Agenda">
            <A href={`/decks/${props.faction}/${deck.agenda}`}>{deck.agenda}</A>
          </div>
        </td>
        <td>
          <div className="DecksFaction-Percent">
            {Math.round(1000 * deck.percent) / 10}
          </div>
        </td>
        <td>
          <div className="DecksFaction-Played">{deck.played}</div>
        </td>
      </tr>
    );
  });
  console.log(games);
  console.log(decks);
  return (
    <div>
      <h3>FACTION - {props.faction}</h3>
      <table>
        <thead>
          <tr>
            <th
              className="DecksFaction-AgendaHeader"
              onClick={() => handleSort("agenda")}
            >
              <div className="DecksFaction-Agenda">Agenda</div>
            </th>
            <th
              className="DecksFaction-PercentHeader"
              onClick={() => handleSort("percent")}
            >
              <div className="DecksFaction-Percent">Win %</div>
            </th>
            <th
              className="DecksFaction-PlayedHeader"
              onClick={() => handleSort("played")}
            >
              <div className="DecksFaction-Played"># Played</div>
            </th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </div>
  );
};

export default Faction;
