defmodule Day3Part1 do
  # get_max finds the largest number we can that isn't at the end of the list
  def get_max(parts) do
    parts
    |> Enum.with_index()
    |> Enum.reduce({0, 0}, fn {x, index}, acc ->
      max = elem(acc, 0)
      if max < x and index < length(parts) - 1, do: {x, index}, else: acc
    end)
  end

  def solve_line(line) do
    parts = line |> String.codepoints() |> Enum.map(&String.to_integer/1)
    IO.inspect(parts)

    {c1, pos} = get_max(parts) |> IO.inspect()

    # then do it again, but with a list only containing items right of the one we found
    c2 = Enum.max(Enum.slice(parts, (pos + 1)..-1//1))

    String.to_integer("#{c1}#{c2}")
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    ## testing
    # lines = [hd(lines)]

    lines
    |> Enum.map(&solve_line/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end
