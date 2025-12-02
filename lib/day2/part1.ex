defmodule Day2Part1 do
  require Integer

  def test_id_is_repeated(id) do
    len = String.length(id)
    Integer.is_even(len) && String.starts_with?(id, String.slice(id, floor(len / 2), len))
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
