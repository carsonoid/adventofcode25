defmodule Day4Part2 do
  def get_neighbors(grid_map, {x, y}) do
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
    |> Enum.map(fn coord -> {coord, Map.get(grid_map, coord)} end)
    |> Enum.filter(&(elem(&1, 1) !== nil))
  end

  def should_remove_cell?(grid_map, {x, y}) do
    contents = Map.get(grid_map, {x, y})

    if contents != "@" do
      false
    else
      get_neighbors(grid_map, {x, y})
      |> Enum.filter(&(elem(&1, 1) === "@"))
      |> Enum.count() < 4
    end
  end

  def get_removable(max_x, max_y, grid_map) do
    for x <- 0..max_x,
        y <- 0..max_y do
      coord = {x, y}
      if should_remove_cell?(grid_map, coord), do: {1, coord}
    end
    |> List.flatten()
    |> Enum.filter(& &1)
    |> IO.inspect()
  end

  def remove_until_empty(max_x, max_y, grid_map, acc) do
    removable = get_removable(max_x, max_y, grid_map)

    if length(removable) == 0 do
      acc
    else
      newgrid_map =
        Enum.reduce(removable, grid_map, fn {_val, coord}, gMap ->
          Map.put(gMap, coord, " ")
        end)

      remove_until_empty(max_x, max_y, newgrid_map, acc + length(removable))
    end
  end

  def build_grid_map(lines) do
    for {row, y} <- Enum.with_index(lines),
        {cell, x} <- Enum.with_index(String.codepoints(row)),
        into: %{} do
      {{x, y}, cell}
    end
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    IO.inspect(lines)

    grid =
      lines
      |> Enum.map(&String.codepoints/1)

    grid_map = build_grid_map(lines)

    max_y = length(grid) - 1
    max_x = length(hd(grid)) - 1

    ## iterate the map, replacing removables with " " until there are no more removables
    remove_until_empty(max_x, max_y, grid_map, 0) |> IO.inspect(label: "final removed count")
  end
end
