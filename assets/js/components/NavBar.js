import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const NavBar = () => {
  return (
    <div className="NavBar-wrapper">
      <div className="NavBar-left">
        <A href="/">AGOT Fighting Pits</A>
      </div>
      <div className="NavBar-right">
        <A href="/players">Players</A>
        <A href="/decks">Decks</A>
      </div>
    </div>
  );
};

export default NavBar;
