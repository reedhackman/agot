import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Agenda = props => {
  console.log(props);
  const [current, setCurrent] = useState(true);
  const [allGames, setAllGames] = useState([]);
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
  useEffect(() => {
    if (props.faction && props.agenda) {
      async function fetchData() {
        const response = await fetch(
          `/api/decks/${props.faction}/${props.agenda}`
        );
        const data = await response.json();
        setAllGames(data.games);
        setCurrent(true);
      }
      fetchData();
    }
  }, [props.faction, props.agenda]);
  const games = current ? props.games : allGames;
  let decksObject = {};
  let wins = 0;
  let losses = 0;
  let played = 0;
  games.forEach(game => {
    if (
      game.winner_faction === game.loser_faction &&
      game.winner_agenda === game.loser_agenda
    ) {
      played += 2;
    } else {
      if (
        game.winner_faction === props.faction &&
        game.winner_agenda === props.agenda
      ) {
        if (!decksObject[game.loser_faction]) {
          decksObject[game.loser_faction] = {
            [game.loser_agenda]: {
              wins: 0,
              losses: 0
            }
          };
        } else if (!decksObject[game.loser_faction][game.loser_agenda]) {
          decksObject[game.loser_faction][game.loser_agenda] = {
            wins: 0,
            losses: 0
          };
        }
        decksObject[game.loser_faction][game.loser_agenda].losses++;
        wins++;
        played++;
      } else {
        if (!decksObject[game.winner_faction]) {
          decksObject[game.winner_faction] = {
            [game.winner_agenda]: {
              wins: 0,
              losses: 0
            }
          };
        } else if (!decksObject[game.winner_faction][game.winner_agenda]) {
          decksObject[game.winner_faction][game.winner_agenda] = {
            wins: 0,
            losses: 0
          };
        }
        decksObject[game.winner_faction][game.winner_agenda].wins++;
        losses++;
        played++;
      }
    }
  });
  let decks = [];
  for (let faction in decksObject) {
    for (let agenda in decksObject[faction]) {
      if (faction && agenda && agenda !== "null") {
        decks.push({
          faction: faction,
          agenda: agenda,
          percent:
            decksObject[faction][agenda].wins /
            (decksObject[faction][agenda].wins +
              decksObject[faction][agenda].losses),
          played:
            decksObject[faction][agenda].wins +
            decksObject[faction][agenda].losses
        });
      }
    }
  }
  decks.sort((a, b) => {
    if (asc) {
      if (sortBy === "faction" || sortBy === "agenda") {
        if (a[sortBy].toLowerCase() > b[sortBy].toLowerCase()) {
          return -1;
        } else if (b[sortBy].toLowerCase() > a[sortBy].toLowerCase()) {
          return 1;
        }
        return 0;
      }
      return a[sortBy] - b[sortBy];
    } else {
      if (sortBy === "faction" || sortBy === "agenda") {
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
  console.log(decks);
  const stats = (
    <div>
      <p>Games Played: {played}</p>
      <p>Win Percent: {Math.round((1000 * wins) / (wins + losses)) / 10}</p>
      <p>Most Favorable Matchup: {"current"}</p>
      <p>Least Favorable Matchup: {"current"}</p>
    </div>
  );
  const rows = [];
  decks.forEach(deck => {
    rows.push(
      <tr key={deck.faction + deck.agenda}>
        <td>
          <div className="DecksAgenda-Faction">
            <A href={`/decks/${deck.faction}`}>{deck.faction}</A>
          </div>
        </td>
        <td>
          <div className="DecksAgenda-Agenda">
            <A href={`/decks/${deck.faction}/${deck.agenda}`}>{deck.agenda}</A>
          </div>
        </td>
        <td>
          <div className="DecksAgenda-Percent">
            {Math.round(1000 * deck.percent) / 10}
          </div>
        </td>
        <td>
          <div className="DecksAgenda-Played">{deck.played}</div>
        </td>
      </tr>
    );
  });
  return (
    <div className="DecksAgenda-Wrapper">
      <div className="DecksAgenda-DeckName">
        {props.faction} {props.agenda}
      </div>
      <div className="DecksAgenda-StatsWrapper">
        <h4>Deck Stats</h4>
        <div className="DecksAgenda-StatsTabsWrapper">
          <div
            className="DecksAgenda-StatsTab"
            onClick={() => setCurrent(false)}
          >
            All Time
          </div>
          <div
            className="DecksAgenda-StatsTab"
            onClick={() => setCurrent(true)}
          >
            Current Interval
          </div>
        </div>
        {stats}
        <table>
          <thead>
            <tr>
              <th
                className="DecksAgenda-FactionHeader"
                onClick={() => handleSort("faction")}
              >
                <div className="DecksAgenda-Faction">Faction</div>
              </th>
              <th
                className="DecksAgenda-AgendaHeader"
                onClick={() => handleSort("agenda")}
              >
                <div className="DecksAgenda-Agenda">Agenda</div>
              </th>
              <th
                className="DecksAgenda-PercentHeader"
                onClick={() => handleSort("percent")}
              >
                <div className="DecksAgenda-Percent">Win %</div>
              </th>
              <th
                className="DecksAgenda-PlayedHeader"
                onClick={() => handleSort("played")}
              >
                <div className="DecksAgenda-Played"># Played</div>
              </th>
            </tr>
          </thead>
          <tbody>{rows}</tbody>
        </table>
      </div>
    </div>
  );
};

export default Agenda;
