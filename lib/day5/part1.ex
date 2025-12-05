defmodule Day5Part1 do
  def solve do
    [ranges, ids] = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n\n")

    ranges =
      ranges
      |> String.split("\n")
      |> Enum.map(fn x ->
        String.split(x, "-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)

    ids = ids |> String.split("\n") |> Enum.map(&String.to_integer/1)

    IO.inspect({ranges, ids})

    ids
    |> Enum.map(fn id ->
      found =
        Enum.any?(ranges, fn {s, e} ->
          s <= id and id <= e
        end)

      if found, do: 1, else: 0
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end
