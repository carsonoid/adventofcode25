defmodule Day7Part2 do
  defp do_move(grid, cell, seenMap) do
    case cell do
      nil ->
        {nil, [], 1}

      _ ->
        if Map.has_key?(seenMap, {cell.x, cell.y}) do
          {nil, []}
        else
          case cell do
            %{value: value} ->
              case value do
                "^" ->
                  {
                    cell,
                    [
                      Grid.get_relative(grid, cell, :left),
                      Grid.get_relative(grid, cell, :right)
                    ],
                    Map.get(seenMap, cell, 0)
                  }

                "." ->
                  do_move(grid, Grid.get_relative(grid, cell, :down), seenMap)
              end
          end
        end
    end
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    # remove every other line to simplify
    lines =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> rem(i, 2) == 0 end)
      |> Enum.map(fn {line, _} -> line end)

    grid = Grid.from_lines(lines) |> Grid.inspect()
    # start = Grid.find(grid, "S") |> IO.inspect(label: :start)

    # collect the cell above every "^" cell left to right bottom to top
    cells =
      Grid.find_all(grid, "^")
      |> Enum.sort_by(fn cell -> {-cell.y, cell.x} end)
      |> IO.inspect(label: :cells)

    cells
    |> Enum.reduce(%{}, fn cell, seenMap ->
      {splitpoint, new_beams, count} = do_move(grid, cell, seenMap)

      count =
        new_beams
        |> Enum.reduce(count, fn b, acc ->
          {_, _, count} = do_move(grid, b, seenMap)
          acc + count
        end)

      Map.put(seenMap, splitpoint, count)
    end)
    |> IO.inspect()
    |> Enum.reduce(0, fn {_, v}, acc ->
      if v > acc do
        v
      else
        acc
      end
    end)
    |> IO.inspect()
  end
end
