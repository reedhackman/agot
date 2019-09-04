import React, { useState, useEffect } from "react";
import { A } from "hookrouter";

const Agenda = props => {
  console.log(props);
  return (
    <div>
      <p>
        {props.faction} {props.agenda}
      </p>
      <div>UNDER CONSTRUCTION</div>
    </div>
  );
};

export default Agenda;
