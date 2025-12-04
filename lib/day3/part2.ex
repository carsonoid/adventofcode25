defmodule Day3Part2 do
  def solve_line(line) do
    parts = line |> String.codepoints() |> Enum.map(&String.to_integer/1)

    IO.inspect(parts)

    parts
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {part, i}, final ->
      IO.inspect(final, charlists: :as_lists)

      cond do
        length(final) + length(parts) - i === 12 ->
          num_left = 12 - length(final)
          result = final ++ Enum.slice(parts, i..(i + num_left - 1))
          {:halt, result}

        true ->
          index =
            final
            |> Enum.find_index(&(part > &1))

          IO.inspect(index, label: "index for part #{part} at position #{i}")

          result =
            if index === nil do
              final ++ [part]
            else
              # index can't be any more left of the current position then there
              # are chars right of the curent position
              # Ex: 811111111111 trying to place 9 with nothing remaining we need to put 9 in the last position
              # instead of replacing 8 which is what would normally happen

              # For example adding 9 to this:
              # [8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
              # [8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 1, 1, 1]
              # we need to resolve index 11 as the target

              number_of_digits_left =
                length(parts) - i - 1

              IO.inspect(number_of_digits_left,
                label: "number_of_digits_left for part #{part} at position #{i}"
              )

              index =
                if 12 - index > number_of_digits_left do
                  11 - number_of_digits_left
                else
                  index
                end

              IO.inspect("new index: #{index} for part #{part} at position #{i}")

              # put the part at index at truncate the list after
              List.insert_at(final, index, part) |> Enum.take(index + 1)
            end

          {:cont, result}
      end
    end)
    |> Enum.take(12)
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
    |> Enum.sum()
    |> IO.inspect(label: "final result")
  end
end
