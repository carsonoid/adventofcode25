defmodule Day3Part2 do
  def solve_line(line) do
    parts = line |> String.codepoints() |> Enum.map(&String.to_integer/1)

    IO.inspect(parts)

    parts
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {part, i}, final ->
      if length(final) + length(parts) - i === 12 do
        num_left = 12 - length(final)
        result = final ++ Enum.slice(parts, i..(i + num_left - 1))
        {:halt, result}
      else
        index =
          final
          |> Enum.find_index(fn val -> part > val end)

        result =
          if index === nil do
            final ++ [part]
          else
            # put the part at index at truncate the list after

            List.insert_at(final, index, part)
            |> Enum.take(index + 1)
          end

        {:cont, result}
      end
    end)
    |> Enum.join()
    |> String.to_integer()
    |> IO.inspect(label: "result")
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    # testing
    # lines = [Enum.at(lines, 3)]

    lines
    |> Enum.map(&solve_line/1)
  end
end
