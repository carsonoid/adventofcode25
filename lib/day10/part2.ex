defmodule Day10Part2 do
  defmodule Bwise do
    def list_xor([], l),
      do: l

    def list_xor(l, []),
      do: l

    def list_xor([h1 | t1], [h2 | t2]),
      do: [:erlang.bxor(h1, h2) | list_xor(t1, t2)]
  end

  defmodule RC do
    def comb(_, 0), do: [[]]
    def comb([], _), do: []

    def comb([h | t], m) do
      for(l <- comb(t, m - 1), do: [h | l]) ++ comb(t, m)
    end

    def powset(l) do
      powset(l, length(l))
    end

    def powset(l, m) do
      Enum.reduce(0..m, [], fn i, acc ->
        acc ++ comb(l, i)
      end)
    end
  end

  defmodule Machine do
    defstruct joltage: {}, target: {}, button_sets: {}

    def new(line) do
      # [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
      [_, _lights_in, button_sets_in, joltage_in] =
        Regex.run(~r"\[([.|#]+)\] ([\(\d\), ]+) \{(.*)\}", line)

      target =
        joltage_in
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      joltage = Enum.map(1..length(target), fn _ -> 0 end)

      button_sets =
        String.split(button_sets_in)
        |> Enum.map(fn b ->
          vals =
            b
            |> String.trim_leading("(")
            |> String.trim_trailing(")")
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)

          Enum.map(1..length(joltage), fn i ->
            if Enum.member?(vals, i - 1), do: 1, else: 0
          end)
        end)

      %Machine{
        joltage: joltage,
        target: target,
        button_sets: button_sets
      }
    end

    def possible_button_sets(button_sets, current, target) do
      # TODO: prune sets that will overshoot the target based on current

      button_sets
      |> Enum.map(fn bs ->
        {bs, rank(target, current, bs)}
      end)
      |> Enum.sort_by(&elem(&1, 1), :desc)
      |> Enum.reject(&(elem(&1, 1) < 0))
    end

    def rank(target, current, button_set) do
      # any one in a target position = 0 means it has negative score

      # each 1 in a target position > 0 adds 1 to score
      # target  | button | score
      # [3,3,1] | [1,1,1] | 3
      # [3,3,1] | [1,1,0] | 2
      # [3,3,1] | [1,0,0] | 1
      # [3,3,1] | [0,0,0] | 0
      # [3,3,0] | [1,1,0] | 2

      # any 1 in a position where current[i] == target[i] means it has a negative score

      ranks =
        for {b, i} <- Enum.with_index(button_set) do
          t = Enum.at(target, i)
          c = Enum.at(current, i)

          cond do
            c == t and b == 1 ->
              -1

            t == 0 and b == 1 ->
              -1

            t > 0 and b == 1 ->
              1

            true ->
              0
          end
        end

      # never include buttons with a negative
      if Enum.member?(ranks, -1) do
        -1
      else
        ranks
        |> Enum.sum()
      end
    end

    def state(cur, target) do
      cond do
        cur == target ->
          :solved

        Enum.zip(cur, target)
        |> Enum.any?(fn {a, b} -> a > b end) ->
          :overshoot

        true ->
          :continue
      end
    end

    def press(cur, button_set) do
      Enum.zip(cur, button_set)
      |> Enum.map(fn {a, b} -> a + b end)
    end

    def dfs(current, target, all_choices) do
      IO.inspect("Starting DFS from #{inspect(current)} to #{inspect(target)}")
      dfs(current, target, all_choices, 0)
    end

    def dfs(_, _, [], _) do
      :error
    end

    def dfs(current, target, all_choices, count) do
      case state(current, target) do
        :solved ->
          IO.inspect("Solved #{target} in #{count} presses")
          {:ok, count}

        :overshoot ->
          :error

        :continue ->
          # IO.inspect("Current: #{inspect(current)} Target: #{inspect(target)}")

          next =
            possible_button_sets(all_choices, current, target)
            |> Enum.map(&elem(&1, 0))

          Enum.reduce_while(next, :error, fn b, _acc ->
            current = press(current, b)
            result = dfs(current, target, next, count + 1)

            case result do
              {:ok, count} -> {:halt, {:ok, count}}
              :error -> {:cont, :error}
            end
          end)
      end
    end
  end

  def get_z3_input(machine) do
    [
      # constants
      for i <- 0..(length(machine.button_sets) - 1) do
        "(declare-const b#{i} Int)"
      end
      |> Enum.join("\n"),
      # non-negative asserts
      for i <- 0..(length(machine.button_sets) - 1) do
        "(assert (>= b#{i} 0))"
      end
      |> Enum.join("\n"),
      # assert values
      # first iterate all positions
      for i <- 0..(length(machine.target) - 1) do
        sum_terms =
          for bs <- machine.button_sets do
            Enum.at(bs, i)
          end
          |> IO.inspect()
          |> Enum.with_index()
          |> Enum.filter(fn {v, _} -> v == 1 end)
          |> Enum.map(fn {_, i} -> "b#{i}" end)
          |> Enum.join(" ")

        "(assert (= (+ #{sum_terms}) #{Enum.at(machine.target, i)}))"
      end
      |> Enum.join("\n"),
      # minimize
      "(minimize (+ " <>
        (for i <- 0..(length(machine.button_sets) - 1) do
           "b#{i}"
         end
         |> Enum.join(" ")) <> "))",
      "(check-sat)",
      "(get-model)"
    ]
    |> Enum.join("\n")
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    # Works for sample! But I'm done and will just use someone else's linear solver
    # for line <- lines do
    #   m = Machine.new(line)
    #   Machine.dfs(m.joltage, m.target, m.button_sets)
    # end
    # |> IO.inspect()
    # |> Enum.map(&elem(&1, 1))
    # |> Enum.sum()
    # |> IO.inspect(label: :result)

    for line <- lines do
      m = Machine.new(line)

      IO.inspect(m)

      content =
        get_z3_input(m)

      IO.puts(content)

      File.write!("/tmp/z3.in", content)

      {result, err} =
        System.cmd("z3", ["/tmp/z3.in"])
        |> IO.inspect()

      if err != 0 do
        IO.inspect(err)
        raise("error")
      end

      Regex.scan(~r"Int\n\s+(\d+)\)?", result)
      |> IO.inspect()
      |> Enum.map(&tl/1)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
      |> IO.inspect()
    end
    |> Enum.sum()
    |> IO.inspect(label: :final)
  end
end
