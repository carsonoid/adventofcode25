defmodule Day9Part1 do
  defmodule RC do
    def comb(_, 0), do: [[]]
    def comb([], _), do: []

    def comb([h | t], m) do
      for(l <- comb(t, m - 1), do: [h | l]) ++ comb(t, m)
    end
  end

  defp get_area({x1, y1}, {x2, y2}) do
    max_x = max(x1, x2)
    max_y = max(y1, y2)
    min_x = min(x1, x2)
    min_y = min(y1, y2)

    (max_x - min_x + 1) * (max_y - min_y + 1)
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    IO.inspect(lines)

    points =
      lines
      |> Enum.map(fn line ->
        line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)

    points
    |> RC.comb(2)
    |> IO.inspect()
    |> Enum.map(fn [p1, p2] ->
      get_area(p1, p2)
    end)
    |> Enum.max()
    |> IO.inspect()
  end
end
