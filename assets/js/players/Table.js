import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Table = props => {
  let data = props.state.players;
  let rows = [];
  let list = [];
  data.sort((a, b) => {
    if (props.state.asc) {
      if (props.state.sortBy === "name") {
        if (
          a[props.state.sortBy].toLowerCase() >
          b[props.state.sortBy].toLowerCase()
        ) {
          return -1;
        }
        if (
          b[props.state.sortBy].toLowerCase() >
          a[props.state.sortBy].toLowerCase()
        ) {
          return 1;
        }
        return 0;
      }
      return a[props.state.sortBy] - b[props.state.sortBy];
    }
    if (props.state.sortBy === "name") {
      if (
        a[props.state.sortBy].toLowerCase() >
        b[props.state.sortBy].toLowerCase()
      ) {
        return 1;
      }
      if (
        b[props.state.sortBy].toLowerCase() >
        a[props.state.sortBy].toLowerCase()
      ) {
        return -1;
      }
      return 0;
    }
    return b[props.state.sortBy] - a[props.state.sortBy];
  });
  data.forEach(player => {
    if (
      player.name.toLowerCase().indexOf(props.state.input.toLowerCase()) !==
        -1 &&
      player.played >= props.state.min
    ) {
      rows.push(player);
    }
  });
  let j = Math.max((props.state.page - 1) * 20, 0);
  let k = rows.length - j;
  for (let i = 0; i < Math.min(k, 20); i++) {
    let player = rows[j];
    list.push(
      <tr key={player.name} className="table-row">
        <td className="players-table-name">
          <A href={`/players/${player.id}`}>{player.name}</A>
        </td>
        <td className="players-table-rating">{Math.round(player.rating)}</td>
        <td className="players-table-percent">
          {(player.percent * 100).toFixed(1)}
        </td>
        <td className="players-table-played">{player.played}</td>
      </tr>
    );
    j++;
  }
  const nav = (
    <div className="navbuttons">
      {props.state.page === 1 ? null : (
        <div
          onClick={() => props.handlePage(1)}
          className="button-table button-left"
        >
          First
        </div>
      )}
      {props.state.page === 1 ? null : (
        <div
          onClick={() => props.handlePage(props.state.page - 1)}
          className="button-table button-left"
        >
          Prev
        </div>
      )}
      <span>
        props.state.page {props.state.page} of {props.state.last}
      </span>
      {props.state.page === props.state.last ? null : (
        <div
          onClick={() => props.handlePage(props.state.page + 1)}
          className="button-table button-right"
        >
          Next
        </div>
      )}
      {props.state.page === props.state.last ? null : (
        <div
          onClick={() => props.handlePage(props.state.last)}
          className="button-table button-right"
        >
          props.state.last
        </div>
      )}
    </div>
  );
  const minbox = (
    <div className="minbox">
      <input
        type="number"
        value={props.state.min}
        onChange={e => props.handleMin(e.target.value)}
      />
      <span> Minimum number of games played</span>
    </div>
  );
  const search = (
    <div className="searchbox">
      <input
        type="text"
        placeholder="Search By Player Name..."
        value={props.state.input}
        onChange={e => props.handleSearch(e.target.value)}
        change="input"
      />
      <span> Search only players whose names match this string</span>
    </div>
  );
  return (
    <div className="table-wrapper">
      <div className="table-filter-box">
        {search}
        {minbox}
      </div>
      <table className="players-table">
        <thead>
          <tr>
            <th className="players-table-name">
              {props.state.sortBy === name ? (
                <div
                  onClick={() => props.handleSort("name")}
                  value="name"
                  className="reactButtonPrimary"
                >
                  {props.state.asc ? (
                    <i className="la la-sort-alpha-asc"></i>
                  ) : (
                    <i className="la la-sort-alpha-desc"></i>
                  )}
                  name
                </div>
              ) : (
                <div
                  onClick={() => props.handleSort("name")}
                  value="name"
                  className="reactButton"
                >
                  name
                </div>
              )}
            </th>
            <th className="players-table-rating">
              {props.state.sortBy === "rating" ? (
                <div
                  onClick={() => props.handleSort("rating")}
                  value="rating"
                  className="reactButtonPrimary"
                >
                  {props.state.asc ? (
                    <i className="la la-sort-numeric-asc"></i>
                  ) : (
                    <i className="la la-sort-numeric-desc"></i>
                  )}
                  Rating
                </div>
              ) : (
                <div
                  onClick={() => props.handleSort("rating")}
                  value="rating"
                  className="reactButton"
                >
                  Rating
                </div>
              )}
            </th>
            <th className="players-table-percent">
              {props.state.sortBy === "percent" ? (
                <div
                  onClick={() => props.handleSort("percent")}
                  value="percent"
                  className="reactButtonPrimary"
                >
                  {props.state.asc ? (
                    <i className="la la-sort-numeric-asc"></i>
                  ) : (
                    <i className="la la-sort-numeric-desc"></i>
                  )}
                  Win Percent
                </div>
              ) : (
                <div
                  onClick={() => props.handleSort("percent")}
                  value="percent"
                  className="reactButton"
                >
                  Win Percent
                </div>
              )}
            </th>
            <th className="players-table-played">
              {props.state.sortBy === "played" ? (
                <div
                  onClick={() => props.handleSort("played")}
                  value="played"
                  className="reactButtonPrimary"
                >
                  {props.state.asc ? (
                    <i className="la la-sort-numeric-asc"></i>
                  ) : (
                    <i className="la la-sort-numeric-desc"></i>
                  )}
                  Games Played
                </div>
              ) : (
                <div
                  onClick={() => props.handleSort("played")}
                  value="played"
                  className="reactButton"
                >
                  Games Played
                </div>
              )}
            </th>
          </tr>
        </thead>
        <tbody>{list}</tbody>
      </table>
      <div className="table-nav-buttons">{nav}</div>
    </div>
  );
};

export default Table;
