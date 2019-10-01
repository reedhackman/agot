import React, { useState, useEffect } from "react";
import { useRoutes } from "hookrouter";
import Players from "./players/Players.js";

const App = props => {
  const routes = {
    "/": () => <div>home</div>,
    "/players/*": () => <Players />
  };
  const routeResult = useRoutes(routes);
  return <div>{routeResult}</div>;
};

export default App;
