defmodule Day4Part1 do
  def get_neighbors(grid, {x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
    |> Enum.map(fn coord -> {coord, Map.get(grid, coord)} end)
    |> Enum.filter(&(elem(&1, 1) !== nil))
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    IO.inspect(lines)

    grid =
      lines
      |> Enum.map(&String.codepoints/1)

    {gridMap, _} =
      Enum.reduce(grid, {%{}, 0}, fn row, {gridMap, accY} ->
        {gridMap, _} =
          Enum.reduce(row, {gridMap, 0}, fn cell, {gridMap, accX} ->
            {
              gridMap |> Map.put({accX, accY}, cell),
              accX + 1
            }
          end)

        {gridMap, accY + 1}
      end)

    for y <- 0..(length(grid) - 1) do
      for x <- 0..(length(hd(grid)) - 1) do
        contents = Map.get(gridMap, {x, y})

        if contents != "@" do
          0
        else
          num_adj =
            get_neighbors(gridMap, {x, y})
            |> Enum.filter(&(elem(&1, 1) === "@"))
            |> Enum.count()

          if num_adj < 4 do
            1
          else
            0
          end
        end
      end
    end
    |> IO.inspect()
    |> List.flatten()
    |> Enum.sum()
    |> IO.inspect()
  end
end
