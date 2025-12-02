defmodule Day1 do
  def get_turns(dir, amt) do
    {amt, _} = Integer.parse(amt)

    if dir === "L" do
      amt * -1
    else
      amt
    end
  end

  def part1 do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    turns =
      lines
      |> Enum.map(&String.split_at(&1, 1))

    IO.inspect(turns)

    pos = 50

    {final_pos, zero_count} =
      Enum.reduce(turns, {pos, 0}, fn {dir, amt}, {current_pos, count} ->
        new_pos = rem(current_pos + get_turns(dir, amt), 100)
        new_pos = if new_pos < 0, do: new_pos + 100, else: new_pos
        IO.puts("current: #{current_pos}, new: #{new_pos}")
        new_count = if new_pos == 0, do: count + 1, else: count
        {new_pos, new_count}
      end)

    IO.puts("Final position: #{final_pos}")
    IO.puts("Times position was 0: #{zero_count}")

    {final_pos, zero_count}
  end

  def move(pos, dir, amt) do
    turns = get_turns(dir, amt)

    # For part2, we need to count each time we pass through 0 during the rotation
    zero_count = count_zeros_during_rotation(pos, turns)

    # Calculate final position
    new_pos = rem(pos + turns, 100)
    new_pos = if new_pos < 0, do: new_pos + 100, else: new_pos

    {new_pos, zero_count}
  end

  def count_zeros_during_rotation(start_pos, turns) do
    # Normalize position (handle negative remainders)
    new_pos =
      case rem(start_pos + turns, 100) do
        pos when pos < 0 -> pos + 100
        pos -> pos
      end

    # Count full wraps
    count = div(abs(turns), 100)

    # Count partial wraps
    count =
      count +
        if start_pos != 0 and new_pos != 0 do
          cond do
            # Wrapped left
            turns < 0 and new_pos > start_pos -> 1
            # Wrapped right
            turns > 0 and new_pos < start_pos -> 1
            true -> 0
          end
        else
          0
        end

    # Count landed on zero
    count = count + if new_pos == 0, do: 1, else: 0

    count
  end

  def part2 do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    turns =
      lines
      |> Enum.map(&String.split_at(&1, 1))

    IO.inspect(turns)

    pos = 50

    {final_pos, zero_count} =
      Enum.reduce(turns, {pos, 0}, fn {dir, amt}, {current_pos, count} ->
        {new_pos, passes} = move(current_pos, dir, amt)

        IO.puts("current: #{current_pos},  new: #{new_pos}, count: #{count} passes: #{passes}")

        {new_pos, count + passes}
      end)

    IO.puts("Final position: #{final_pos}")
    IO.puts("Times position passed or on 0: #{zero_count}")

    {final_pos, zero_count}
  end
end
