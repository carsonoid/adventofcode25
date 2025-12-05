defmodule Grid do
  defmodule Grid do
    defstruct lines: [], cells: []
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

  def from_lines(lines) do
    from_lines(lines, & &1)
  end

  def from_lines(lines, mutator_fun) do
    %Grid{
      :lines => lines,
      :cells =>
        for {row, y} <- Enum.with_index(lines),
            {cell, x} <-
              Enum.with_index(String.codepoints(row) |> Enum.map(mutator_fun)),
            into: %{} do
          {{x, y}, cell}
        end
    }
  end
end
