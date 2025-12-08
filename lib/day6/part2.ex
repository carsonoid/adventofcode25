defmodule Day6Part2 do
  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.split("\n")

    lines = List.delete_at(lines, -1)

    # make a tuple of tuples for rows
    grid =
      lines
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    IO.inspect(grid)

    for x <- 0..(tuple_size(elem(grid, 0)) - 1),
        y <- 0..(tuple_size(grid) - 1) do
      elem(elem(grid, y), x)
    end
    |> IO.inspect()
    |> Enum.reduce({0, [], ""}, fn c, {r, vals, val_string} ->
      IO.inspect({c, r, vals, val_string})

      case c do
        " " ->
          if val_string !== "" do
            {r, [String.to_integer(val_string) | vals], ""}
          else
            {r, vals, val_string}
          end

        "+" ->
          vals =
            if val_string !== "",
              do: [String.to_integer(val_string) | vals],
              else: vals

          IO.inspect(vals, label: "vals before sum")

          {r + Enum.sum(vals), [], ""}

        "*" ->
          vals =
            if val_string !== "",
              do: [String.to_integer(val_string) | vals],
              else: vals

          IO.inspect(vals, label: "vals before product")

          {r + Enum.product(vals), [], ""}

        _ ->
          {r, vals, val_string <> c}
      end
    end)
    |> elem(0)
    |> IO.inspect(label: :result)
  end
end
