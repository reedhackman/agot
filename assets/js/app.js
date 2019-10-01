import css from "../css/app.css";
import "phoenix_html";
import "react-phoenix";
import App from "./app/App";
import Players from "./app/players/Players.js";
import PlayersSpecificRatingGraph from "./app/players/PlayersSpecificRatingGraph.js";
import PlayersSpecific from "./app/players/PlayersSpecific.js";
import PlayersSpecificDecks from "./app/players/PlayersSpecificDecks.js";
import PlayersSpecificOpponents from "./app/players/PlayersSpecificOpponents.js";
import PlayersTable from "./app/players/PlayersTable.js";

window.Components = {
  App,
  Players,
  PlayersSpecificRatingGraph,
  PlayersSpecific,
  PlayersSpecificDecks,
  PlayersSpecificOpponents,
  PlayersTable
};
