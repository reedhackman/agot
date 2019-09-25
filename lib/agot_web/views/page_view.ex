defmodule AgotWeb.PageView do
  use AgotWeb, :view
  def last_played(player) do
    Map.keys(player.ratings_over_time)
    |> Enum.map(fn x -> NaiveDateTime.from_iso8601!(x) end)
    |> Enum.sort_by(fn d -> {d.year, d.month, d.day} end)
    |> List.last()
    |> NaiveDateTime.to_date()
  end
end
