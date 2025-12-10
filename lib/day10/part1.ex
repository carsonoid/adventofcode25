defmodule Day10Part1 do
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
    defstruct lights: {}, target: {}, button_sets: {}

    def new(line) do
      # [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
      [_, lights_in, button_sets_in, _joltage] =
        Regex.run(~r"\[([.|#]+)\] ([\(\d\), ]+) \{(.*)\}", line)

      lights = Enum.map(1..String.length(lights_in), fn _ -> 0 end)

      target =
        lights_in
        |> String.codepoints()
        |> Enum.map(fn v ->
          if v == ".", do: 0, else: 1
        end)

      button_sets =
        String.split(button_sets_in)
        |> Enum.map(fn b ->
          vals =
            b
            |> String.trim_leading("(")
            |> String.trim_trailing(")")
            |> String.split(",")
            |> Enum.map(&String.to_integer/1)

          Enum.map(1..length(lights), fn i ->
            if Enum.member?(vals, i - 1), do: 1, else: 0
          end)
        end)

      %Machine{
        lights: lights,
        target: target,
        button_sets: button_sets
      }
    end

    def is_solved?(machine) do
      machine.lights == machine.target
    end

    def simulate_press(machine, button_set) do
      Bwise.list_xor(machine.lights, button_set)
    end

    def press(machine, button_set) do
      %{machine | lights: simulate_press(machine, button_set)}
    end

    def press_all(machine, button_sets) do
      button_sets
      |> Enum.reduce(machine, fn button_set, machine ->
        press(machine, button_set)
      end)
    end

    def score(machine, new_lights) do
      # score is the difference between the current lights
      # and the target after pressing the button_sets
      # we can do this by doing an xor an the new state vs the target
      # and counting the incorrect positions (1s)
      # LOWER SCORE is better since it is more accurate
      Bwise.list_xor(new_lights, machine.target)
      |> Enum.sum()
    end

    def solve(machine) do
      # try pressing every combination of buttons once, including combinations where
      # we don't press everything

      RC.powset(machine.button_sets)
      |> Enum.map(fn button_sets ->
        new_machine = press_all(machine, button_sets)
        {length(button_sets), is_solved?(new_machine)}
      end)
      |> Enum.reject(fn result ->
        elem(result, 1) == false
      end)
      |> Enum.sort_by(fn result ->
        elem(result, 0)
      end)
      |> hd()
      |> elem(0)
    end
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    for line <- lines do
      machine = Machine.new(line)
      Machine.solve(machine)
    end
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect(label: :result)
  end
end
