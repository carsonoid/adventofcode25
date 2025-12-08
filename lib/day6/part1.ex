defmodule Day6Part1 do
  def update_line(line, operations_map) do
    line
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(operations_map, fn {val, i}, operations_map ->
      {_, operations_map} =
        Map.get_and_update(operations_map, i, fn vals ->
          new_vals = [val | vals || []]
          {vals, new_vals}
        end)

      operations_map
    end)
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    lines = lines |> Enum.reverse()

    [ops_line | lines] = lines

    operations_map =
      lines
      |> Enum.reduce(%{}, &update_line/2)

    ops_line
    |> String.trim()
    |> String.split()
    |> Enum.with_index()
    |> Enum.map(fn {op, i} ->
      vals = Map.get(operations_map, i)
      IO.inspect({op, vals})

      case op do
        "*" ->
          Enum.product(vals)

        "+" ->
          Enum.sum(vals)
      end
    end)
    |> Enum.sum()
    |> IO.inspect(label: :result)
  end
end
