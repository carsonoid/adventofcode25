defmodule Day7Part1 do
  defp do_move(grid, cell) do
    next = Grid.get_relative(grid, cell, :down)

    if next == nil do
      {nil, []}
    else
      case next.value do
        nil ->
          {nil, []}

        "^" ->
          {
            cell,
            [
              Grid.get_relative(grid, next, :left),
              Grid.get_relative(grid, next, :right)
            ]
          }

        "." ->
          do_move(grid, next)
      end
    end
  end

  defp get_split_map(grid, beams, splitMap, trackedMap) do
    beams
    |> Enum.reduce({splitMap, trackedMap}, fn beam, {splitMap, trackedMap} ->
      IO.inspect(beam, label: :follow)

      {split_point, new_beams} = do_move(grid, beam)

      trackedMap = Map.put(trackedMap, {beam.x, beam.y}, true)

      if new_beams == [] do
        {splitMap, trackedMap}
      else
        get_split_map(
          grid,
          new_beams |> Enum.reject(&Map.get(trackedMap, {&1.x, &1.y})),
          Map.put(splitMap, {split_point.x, split_point.y}, true),
          trackedMap
        )
      end
    end)
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    grid = Grid.from_lines(lines) |> Grid.inspect()
    start = Grid.find(grid, "S") |> IO.inspect(label: :start)

    {splitMap, _trackedMap} = get_split_map(grid, [start], %{}, %{}) |> IO.inspect()

    IO.puts("")

    splitMap
    |> Enum.reduce(grid, fn {coords, _}, grid ->
      Grid.update(grid, coords, "*")
    end)
    |> Grid.inspect()

    splitMap |> Enum.count() |> IO.inspect(label: :result)
  end
end
