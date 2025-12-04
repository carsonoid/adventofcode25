defmodule Day4Part2 do
  def get_neighbors(gridMap, {x, y}) do
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
    |> Enum.map(fn coord -> {coord, Map.get(gridMap, coord)} end)
    |> Enum.filter(&(elem(&1, 1) !== nil))
  end

  def get_removable(max_x, max_y, gridMap) do
    for y <- 0..max_y do
      for x <- 0..max_x do
        contents = Map.get(gridMap, {x, y})

        if contents != "@" do
          {0, {x, y}}
        else
          num_adj =
            get_neighbors(gridMap, {x, y})
            |> Enum.filter(&(elem(&1, 1) === "@"))
            |> Enum.count()

          if num_adj < 4 do
            {1, {x, y}}
          else
            {0, {x, y}}
          end
        end
      end
    end
    |> List.flatten()
    |> Enum.filter(fn {val, _coord} -> val == 1 end)
    |> IO.inspect()
  end

  def remove_until_empty(max_x, max_y, gridMap, acc) do
    removable = get_removable(max_x, max_y, gridMap)

    if length(removable) == 0 do
      acc
    else
      newGridMap =
        Enum.reduce(removable, gridMap, fn {_val, coord}, gMap ->
          Map.put(gMap, coord, " ")
        end)

      remove_until_empty(max_x, max_y, newGridMap, acc + length(removable))
    end
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

    max_y = length(grid) - 1
    max_x = length(hd(grid)) - 1

    ## iterate the map, replacing removables with " " until there are no more removables
    remove_until_empty(max_x, max_y, gridMap, 0) |> IO.inspect(label: "final removed count")
  end
end
