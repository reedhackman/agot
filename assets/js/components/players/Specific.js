import React, { useState, useEffect } from "react";
import Opponents from "./SpecificOpponents";
import Decks from "./SpecificDecks";
import RatingGraph from "./SpecificRatingGraph";

const Specific = props => {
  const [ratingsOverTime, setRatingsOverTime] = useState({});
  const [wins, setWins] = useState([]);
  const [losses, setLosses] = useState([]);
  useEffect(() => {
    if (props.id) {
      async function fetchData() {
        const response = await fetch(`/api/players/specific/${props.id}`);
        const data = await response.json();
        setRatingsOverTime(data.player.ratings_over_time);
        setWins(data.games.wins);
        setLosses(data.games.losses);
      }
      fetchData();
    }
  }, [props.id]);
  let opponents = {};
  let decks = {};
  wins.forEach(win => {
    if (win.loser_id) {
      if (!opponents[win.loser_id]) {
        opponents[win.loser_id] = {
          wins: 1,
          losses: 0,
          name: win.loser_name
        };
      } else {
        opponents[win.loser_id].wins++;
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
    if (loss.winner_id) {
      if (!opponents[loss.winner_id]) {
        opponents[loss.winner_id] = {
          wins: 0,
          losses: 1,
          name: loss.winner_name
        };
      } else {
        opponents[loss.winner_id].losses++;
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
