defmodule Day5Part2 do
  def range_with_id(ranges, id, {exclude_s, exclude_e}) do
    Enum.find(ranges, fn {s, e} ->
      s <= id and id <= e and not (s == exclude_s and e == exclude_e)
    end)
  end

  def range_contains(ranges, {exclude_s, exclude_e}) do
    Enum.find(ranges, fn {s, e} ->
      s <= exclude_s and exclude_e <= e and not (s == exclude_s and e == exclude_e)
    end)
  end

  # OVERLAP EXAMPLES
  #        89  # no overlap
  #    345     # start overlap
  # 12345      # end overlap
  #  234       # start and end overlap
  #
  # if no overlap -> keep range
  # if both overlap -> remove range
  # if only start overlaps -> extend end of matching range to new end
  # if only end overlaps -> extend start of matching range to new start
  def reduce_range(ranges, {s, e}) do
    contained_in = range_contains(ranges, {s, e})
    start_overlaps = range_with_id(ranges, s, {s, e})
    end_overlaps = range_with_id(ranges, e, {s, e})

    cond do
      # fully contained, no longer needed
      contained_in ->
        {List.delete(ranges, {s, e}), :reduced}

      # start overlaps, extend end of match
      start_overlaps ->
        i = Enum.find_index(ranges, fn x -> x == start_overlaps end)

        {List.replace_at(ranges, i, {elem(start_overlaps, 0), e}), :reduced}

      # end overlaps, extend start of match
      end_overlaps ->
        i = Enum.find_index(ranges, fn x -> x == end_overlaps end)
        {List.replace_at(ranges, i, {s, elem(end_overlaps, 1)}), :reduced}

      # no overlap, keep
      true ->
        {ranges, :ok}
    end
  end

  # iterate ranges until there are no changes made after a full iteration of the list
  # that means all ranges have been merged and we just need to sum
  def reduce_ranges(ranges) do
    {ranges, changed} =
      ranges
      |> Enum.reduce({ranges, false}, fn range, {ranges, past_result} ->
        {ranges, result} = reduce_range(ranges, range)
        {ranges, past_result or result !== :ok}
      end)
      |> IO.inspect()

    if changed do
      reduce_ranges(ranges)
    else
      ranges
    end
  end

  def solve do
    [ranges, _] = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n\n")

    ranges =
      ranges
      |> String.split("\n")
      |> Enum.map(fn x ->
        String.split(x, "-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)

    IO.inspect(ranges)

    # reduce_range([{3, 5}, {10, 14}, {16, 20}, {12, 18}], {10, 14})
    # |> reduce_range({10, 14})
    # |> reduce_range({16, 20})
    # |> reduce_range({16, 20})
    # |> IO.inspect()

    # {ranges, _} = reduce_range(ranges, {10, 14}) |> IO.inspect()

    reduce_ranges(ranges)
    |> Enum.uniq()
    |> IO.inspect()
    |> Enum.map(fn {s, e} ->
      e - s + 1
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end
