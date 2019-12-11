import React from "react";
import Table from "./Table";

const TableWrapper = ({ players }) => {
  const columns = [
    { Header: "Name", accessor: "name" },
    {
      Header: "Win Percent",
      accessor: "percent",
      Cell: cellInfo => <>{Math.round(cellInfo.cell.value * 1000) / 10}</>
    },
    {
      Header: "Rating",
      accessor: "rating",
      Cell: cellInfo => <>{Math.round(cellInfo.cell.value)}</>
    },
    {
      Header: "Games Played",
      accessor: "played"
    }
  ];
  const data = players;
  return <Table columns={columns} data={data} />;
};

export default TableWrapper;
