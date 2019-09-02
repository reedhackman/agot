import React, { useState, useEffect } from "react";

const Specific = props => {
  console.log(props.player);
  const [ratingsOverTime, setRatingsOverTime] = useState({});
  useEffect(() => {
    if (props.player) {
      async function fetchData() {
        const response = await fetch(`/api/players/${props.player.id}`);
        const data = await response.json();
        setRatingsOverTime(data);
      }
      fetchData();
    }
  }, [props.player]);
  console.log(ratingsOverTime);
  return (
    <div>
      {props.player ? (
        <div>
          <p>Name: {props.player.name}</p>
          <p>Rating: {props.player.rating}</p>
          <p>Win Rate: {Math.round(1000 * props.player.percent) / 10}%</p>
          <p>Games Played: {props.player.played}</p>
        </div>
      ) : (
        <p>LOADING</p>
      )}
    </div>
  );
};

export default Specific;
