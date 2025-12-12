defmodule Day12Part1 do
  def print_cells(cells) do
    IO.puts("")
    cells |> Enum.map(&Enum.join(&1, "")) |> Enum.join("\n") |> IO.puts()
  end

  defmodule Shape do
    defstruct id: 0, cells: [], permutations: []

    def new([_ | t]) do
      cells =
        t
        |> Enum.map(fn row ->
          row
          |> String.codepoints()
          |> Enum.map(
            &case &1 do
              "#" -> 1
              _ -> 0
            end
          )
        end)

      %Shape{
        cells: cells,
        permutations: get_permutations(cells)
      }
    end

    def get_permutations(cells) do
      h = flip_horizontal(cells)
      v = flip_vertical(cells)
      # turn 90 3 times
      # flip horizontal
      # turn 90 3 times
      # flip vertical
      # turn 90 3 times
      # keep unique
      [
        cells,
        rotate_clockwise(cells, 1),
        rotate_clockwise(cells, 2),
        rotate_clockwise(cells, 3),
        h,
        rotate_clockwise(h, 1),
        rotate_clockwise(h, 2),
        rotate_clockwise(h, 3),
        v,
        rotate_clockwise(v, 1),
        rotate_clockwise(v, 2),
        rotate_clockwise(v, 3)
      ]
      |> Enum.uniq()
    end

    def flip_vertical(cells) do
      for y <- (length(cells) - 1)..0//-1 do
        for x <- 0..(length(hd(cells)) - 1) do
          Enum.at(cells, y) |> Enum.at(x)
        end
      end
    end

    def flip_horizontal(cells) do
      for y <- 0..(length(cells) - 1) do
        for x <- (length(hd(cells)) - 1)..0//-1 do
          Enum.at(cells, y) |> Enum.at(x)
        end
      end
    end

    def rotate_clockwise(cells, i) do
      if i == 0 do
        cells
      else
        rotate_clockwise(rotate_clockwise(cells), i - 1)
      end
    end

    def rotate_clockwise(cells) do
      for x <- 0..(length(hd(cells)) - 1) do
        for y <- (length(cells) - 1)..0//-1 do
          Enum.at(cells, y) |> Enum.at(x)
        end
      end
    end

    def rotate_anticlockwise(cells) do
      for x <- (length(hd(cells)) - 1)..0//-1 do
        for y <- 0..(length(cells) - 1) do
          Enum.at(cells, y) |> Enum.at(x)
        end
      end
    end

    def inspect(shape) do
      ("id: #{shape.id}\n" <> (shape.cells |> Enum.map(&Enum.join(&1, "")) |> Enum.join("\n")))
      |> IO.puts()
    end
  end

  defmodule Region do
    defstruct h: 0, w: 0, required_shapes: %{}, state: []

    def new(line) do
      # 4x4: 0 0 0 0 2 0
      [[_, w, h, shapes_raw]] = Regex.scan(~r"(\d+)x(\d+): (.*)", line)

      %Region{
        w: String.to_integer(w),
        h: String.to_integer(h),
        required_shapes:
          shapes_raw
          |> String.split()
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {num, i}, acc ->
            Map.put(acc, i, String.to_integer(num))
          end),
        state: List.duplicate(List.duplicate(0, String.to_integer(w)), String.to_integer(h))
      }
    end

    def try_place(shape, region) do
      # shapes are always 3/3 so no need to try known bad positions
      for x <- 0..(region.w - 3),
          y <- 0..(region.h - 3) do
        new_cells = place(shape.cells, region.state, x, y)

        if List.flatten(new_cells) |> Enum.any?(&(&1 > 1)) do
          {:no_fit, new_cells}
        else
          {:yes_fit, new_cells}
        end
      end
    end

    def place(cells, grid, x_offset, y_offset) do
      for y <- 0..(length(grid) - 1) do
        if y >= y_offset and y < y_offset + length(cells) do
          for x <- 0..(length(hd(grid)) - 1) do
            grid_val = Enum.at(grid, y) |> Enum.at(x)

            if x >= x_offset and x < x_offset + length(hd(cells)) do
              grid_val +
                (Enum.at(cells, y - y_offset) |> Enum.at(x - x_offset))
            else
              grid_val
            end
          end
        else
          Enum.at(grid, y)
        end
      end
    end

    def solve(_shapes) do
    end
  end

  def solve do
    parts =
      File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n\n") |> IO.inspect()

    {raw_regions, raw_shapes} = List.pop_at(parts, length(parts) - 1)

    IO.inspect({raw_regions, raw_shapes})

    _shapes =
      for s <- raw_shapes do
        Shape.new(String.split(s, "\n"))
      end

    regions =
      for r <- String.split(raw_regions, "\n") do
        Region.new(r)
      end

    for r <- regions do
      num_presents =
        for {_, v} <- r.required_shapes do
          v
        end
        |> Enum.sum()

      # no packing, just check size!
      if num_presents * 3 * 3 <= r.h * r.w do
        1
      else
        0
      end
    end
    |> Enum.sum()
    |> IO.inspect(label: "Xmas answer")
  end
end
