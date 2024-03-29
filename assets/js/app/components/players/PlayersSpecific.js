import React, { useState, useEffect } from "react";
import Opponents from "./PlayersSpecificOpponents";
import Decks from "./PlayersSpecificDecks";
import RatingGraph from "./PlayerSpecificRatingGraph";

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
  console.log(wins);
  console.log(losses);
  wins.forEach(win => {
    if (win.loser.id) {
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
    }
  });
  losses.forEach(loss => {
    if (loss.winner.id) {
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
    }
  });
  let ratingDates = Object.keys(ratingsOverTime);
  ratingDates.sort((a, b) => {
    return new Date(a) > new Date(b) ? 1 : new Date(b) > new Date(a) ? -1 : 0;
  });
  let lastPlayed = ratingDates[ratingDates.length - 1];
  if (lastPlayed) {
    lastPlayed = lastPlayed.slice(0, 10);
  }
  console.log(typeof lastPlayed);
  return (
    <div>
      {props.player ? (
        <div>
          <div>
            <p>Name: {props.player.name}</p>
            <p>Rating: {Math.round(props.player.rating)}</p>
            <p>Win Rate: {Math.round(1000 * props.player.percent) / 10}%</p>
            <p>Games Played: {props.player.played}</p>
            <p>Last Played : {lastPlayed ? lastPlayed : "N/A"}</p>
          </div>
          <RatingGraph ratingsOverTime={ratingsOverTime} />
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
