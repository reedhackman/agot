defmodule Agot.Tjp.Api do
  def get_games_by_page(list, page, i \\ 0) do
    url = "https://thejoustingpavilion.com/api/v3/games?page=" <> Integer.to_string(page)

    case HTTPoison.get(url, [], ssl: [{:versions, [:"tlsv1.2"]}], follow_redirect: true) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Poison.decode!(body)
        index = length(data)
        new_data = Enum.slice(data, i..index)
        IO.inspect(url <> " length: " <> Integer.to_string(index))

        if index === 50 do
          get_games_by_page(list ++ new_data, page + 1)
        else
          IO.inspect(Integer.to_string(length(list ++ new_data)) <> " new games")
          {:ok, list ++ new_data, page, index}
        end

      {:error, _reason} ->
        get_games_by_page(list, page, i)
    end
  end

  def get_games_by_tournament_id(list, id, page \\ 1) do
    url = "https://thejoustingpavilion.com/api/v3/games?page=#{page}&tournament_id=#{id}"

    case HTTPoison.get(url, [], ssl: [{:versions, [:"tlsv1.2"]}], follow_redirect: true) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Poison.decode!(body)
        index = length(data)

        if index === 50 do
          get_games_by_tournament_id(list ++ data, id, page + 1)
        else
          {:ok, list ++ data}
        end

      {:error, _reason} ->
        get_games_by_tournament_id(list, id, page)
    end
  end
end
