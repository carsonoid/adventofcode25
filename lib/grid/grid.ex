defmodule(Grid) do
  defmodule Cell do
    defstruct x: 0, y: 99, value: ""
  end

  defmodule Grid do
    defstruct lines: [], cells: [], max_x: 0, max_y: 0
  end

  def get_neighbor_cells(grid, {x, y}, opts \\ [include_empty: false]) do
    cells =
      [
        {x - 1, y - 1},
        {x, y - 1},
        {x + 1, y - 1},
        {x - 1, y},
        {x + 1, y},
        {x - 1, y + 1},
        {x, y + 1},
        {x + 1, y + 1}
      ]
      |> Enum.map(fn coord -> {coord, Map.get(grid.cells, coord)} end)

    filtered_cells =
      if Keyword.get(opts, :include_empty, false) do
        cells
      else
        cells |> Enum.filter(&(elem(&1, 1) !== nil))
      end

    # Convert list of {coord, value} tuples to map
    filtered_cells |> Enum.into(%{})
  end

  def find(grid, val) do
    Enum.find(grid.cells, fn {_k, v} -> v.value == val end) |> elem(1)
  end

  def find_all(grid, val) do
    Enum.filter(grid.cells, fn {_k, v} -> v.value == val end) |> Enum.map(&elem(&1, 1))
  end

  def get(grid, %Cell{x: x, y: y}) do
    get(grid, {x, y})
  end

  def get(grid, {x, y}) do
    Map.get(grid.cells, {x, y})
  end

  def get_relative(grid, %Cell{x: x, y: y}, dir) do
    get_relative(grid, {x, y}, dir)
  end

  def get_relative(grid, {x, y}, dir) do
    case dir do
      :left -> Map.get(grid.cells, {x - 1, y})
      :right -> Map.get(grid.cells, {x + 1, y})
      :up -> Map.get(grid.cells, {x, y - 1})
      :down -> Map.get(grid.cells, {x, y + 1})
    end
  end

  def inspect(grid) do
    for y <- 0..grid.max_y do
      for x <- 0..grid.max_x do
        cell = get(grid, {x, y})
        IO.write(cell.value)
      end

      IO.write("\n")
    end

    grid
  end

  def update(%Grid{} = grid, %Cell{x: x, y: y}, val) do
    update(grid, {x, y}, val)
  end

  def update(%Grid{} = grid, {x, y}, val) do
    {_, cells} =
      Map.get_and_update(grid.cells, {x, y}, fn _old_val ->
        {
          nil,
          %Cell{x: x, y: y, value: val}
        }
      end)

    %Grid{grid | cells: cells}
  end

  def new(width, height) do
    for _ <- 0..(height - 1) do
      String.duplicate(".", width)
    end
    |> from_lines()
  end

  def from_lines(lines) do
    from_lines(lines, & &1)
  end

  def from_lines(lines, mutator_fun) do
    %Grid{
      :max_x => (hd(lines) |> String.codepoints() |> length()) - 1,
      :max_y => length(lines) - 1,
      :lines => lines,
      :cells =>
        for {row, y} <- Enum.with_index(lines),
            {val, x} <-
              Enum.with_index(String.codepoints(row) |> Enum.map(mutator_fun)),
            into: %{} do
          {{x, y}, %Cell{x: x, y: y, value: val}}
        end
    }
  end
end
