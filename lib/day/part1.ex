defmodule DayXPart1 do
  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    IO.inspect(lines)
  end
end
