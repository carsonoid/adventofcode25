defmodule Day2Part2 do
  require Integer

  def test_id_is_repeated(id) do
    len = String.length(id)

    len > 1 &&
      Enum.any?(1..floor(len / 2), fn i ->
        if rem(len, i) != 0 do
          # i must evenly divide into the string length for a match to even be possible
          false
        else
          # check for repeated match
          prefix = String.slice(id, 0, i)
          reps = floor(len / i)
          id === String.duplicate(prefix, reps)
        end
      end)
  end

  def test_id(id) do
    String.starts_with?(id, "0") || test_id_is_repeated(id)
  end

  def test_range({first, last}) do
    Enum.map(String.to_integer(first)..String.to_integer(last), fn id ->
      if test_id(Integer.to_string(id)), do: id, else: 0
    end)
    |> Enum.sum()
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    hd(lines)
    |> String.split(",")
    |> Enum.map(fn pair ->
      String.split(pair, "-")
      |> List.to_tuple()
    end)
    |> IO.inspect()
    |> Enum.map(&test_range(&1))
    |> Enum.sum()
    |> IO.inspect()
  end
end
