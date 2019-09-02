import React, { useState, useEffect } from "react";
import Opponents from "./PlayersSpecificOpponents";
import Decks from "./PlayersSpecificDecks";

const Specific = props => {
  const [ratingsOverTime, setRatingsOverTime] = useState({});
  const [wins, setWins] = useState([]);
  const [losses, setLosses] = useState([]);
  useEffect(() => {
    if (props.player) {
      async function fetchData() {
        const response = await fetch(`/api/players/${props.player.id}`);
        const data = await response.json();
        setRatingsOverTime(data.ratings_over_time);
        setWins(data.wins);
        setLosses(data.losses);
      }
      fetchData();
    }
  }, [props.player]);
  let opponents = {};
  let decks = {};
  wins.forEach(win => {
    if (!opponents[win.loser.id]) {
      opponents[win.loser.id] = {
        wins: 1,
        losses: 0,
        name: win.loser.name
      };
    } else {
      opponents[win.loser.id].wins++;
    }
    if (!decks[win.faction]) {
      decks[win.faction] = {
        [win.agenda]: {
          wins: 1,
          losses: 0
        }
      };
    } else if (!decks[win.faction][win.agenda]) {
      decks[win.faction][win.agenda] = {
        wins: 1,
        losses: 0
      };
    } else {
      decks[win.faction][win.agenda].wins++;
    }
  });
  losses.forEach(loss => {
    if (!opponents[loss.winner.id]) {
      opponents[loss.winner.id] = {
        wins: 0,
        losses: 1,
        name: loss.winner.name
      };
    } else {
      opponents[loss.winner.id].losses++;
    }
    if (!decks[loss.faction]) {
      decks[loss.faction] = {
        [loss.agenda]: {
          wins: 0,
          losses: 1
        }
      };
    } else if (!decks[loss.faction][loss.agenda]) {
      decks[loss.faction][loss.agenda] = {
        wins: 0,
        losses: 1
      };
    } else {
      decks[loss.faction][loss.agenda].losses++;
    }
  });
  return (
    <div>
      {props.player ? (
        <div>
          <div>
            <p>Name: {props.player.name}</p>
            <p>Rating: {Math.round(props.player.rating)}</p>
            <p>Win Rate: {Math.round(1000 * props.player.percent) / 10}%</p>
            <p>Games Played: {props.player.played}</p>
          </div>
          <Opponents opponents={opponents} />
          <Decks decks={decks} />
        </div>
      ) : (
        <p>LOADING</p>
      )}
    </div>
  );
};

export default Specific;
