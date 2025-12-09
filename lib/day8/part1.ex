defmodule Day8Part1 do
  defmodule RC do
    def comb(_, 0), do: [[]]
    def comb([], _), do: []

    def comb([h | t], m) do
      for(l <- comb(t, m - 1), do: [h | l]) ++ comb(t, m)
    end
  end

  defp get_dist({p1, p2}) do
    get_dist(p1, p2)
  end

  defp get_dist({x1, y1, z1}, {x2, y2, z2}) do
    :math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2 + (z1 - z2) ** 2)
  end

  defp circuit_with(circuits, e) do
    circuits
    |> Enum.with_index()
    |> Enum.find(fn {circuit, _} = c ->
      if Enum.any?(circuit, &(&1 === e)), do: c, else: nil
    end)
  end

  def solve do
    [input_file, limit] = System.argv()
    limit = String.to_integer(limit)

    lines = File.read!(input_file) |> String.trim() |> String.split("\n")

    IO.inspect(lines)

    points =
      for line <- lines do
        line |> String.split(",") |> Enum.map(&String.to_integer/1)
      end
      |> RC.comb(2)
      |> Enum.map(fn x ->
        [p1, p2] = x
        {List.to_tuple(p1), List.to_tuple(p2)}
      end)
      |> Enum.reduce([], fn pair, acc ->
        [{pair, get_dist(pair)} | acc]
      end)
      |> Enum.sort(fn a, b ->
        elem(a, 1) < elem(b, 1)
      end)
      |> Enum.take(limit)

    IO.inspect(points)

    Enum.reduce(points, [], fn {{p1, p2}, _dist}, circuits ->
      match_p1 = circuit_with(circuits, p1)
      match_p2 = circuit_with(circuits, p2)

      cond do
        match_p1 && match_p2 ->
          {c1, c1_index} = match_p1
          {c2, c2_index} = match_p2

          if c1_index == c2_index do
            # ignore if they are in the same circuit
            circuits
          else
            # merge circuits if they are not
            # Delete in descending order of indices to avoid index shifting
            {higher_index, lower_index} =
              if c1_index > c2_index, do: {c1_index, c2_index}, else: {c2_index, c1_index}

            cleaned =
              circuits
              |> List.delete_at(higher_index)
              |> List.delete_at(lower_index)

            [c1 ++ c2 | cleaned]
          end

        match_p1 ->
          {matched, i} = match_p1
          List.replace_at(circuits, i, [p2 | matched])

        match_p2 ->
          {matched, i} = match_p2
          List.replace_at(circuits, i, [p1 | matched])

        true ->
          [[p1, p2] | circuits]
      end
    end)
    |> IO.inspect(label: :final)
    |> Enum.map(&length(&1))
    |> Enum.sort(&(&1 > &2))
    |> IO.inspect()
    |> Enum.take(3)
    |> Enum.product()
    |> IO.inspect(label: :result)
  end
end
