defmodule GrodTest do
  use ExUnit.Case
  doctest Grid

  test "basic" do
    lines = ["abc", "def"]

    assert Grid.from_lines(lines) == %Grid.Grid{
             lines: lines,
             cells: %{
               {0, 0} => "a",
               {1, 0} => "b",
               {2, 0} => "c",
               {0, 1} => "d",
               {1, 1} => "e",
               {2, 1} => "f"
             }
           }
  end

  test "basic_mut" do
    lines = ["123", "456"]

    assert Grid.from_lines(lines, &String.to_integer/1) == %Grid.Grid{
             lines: lines,
             cells: %{
               {0, 0} => 1,
               {1, 0} => 2,
               {2, 0} => 3,
               {0, 1} => 4,
               {1, 1} => 5,
               {2, 1} => 6
             }
           }
  end

  test "get_cells" do
    # abc
    # def
    # ghi
    grid =
      Grid.from_lines(["abc", "def", "ghi"])

    assert Grid.get_neighbor_cells(grid, {1, 1}) == %{
             {0, 0} => "a",
             {1, 0} => "b",
             {2, 0} => "c",
             {0, 1} => "d",
             {2, 1} => "f",
             {0, 2} => "g",
             {1, 2} => "h",
             {2, 2} => "i"
           }

    # include empty
    assert Grid.get_neighbor_cells(grid, {0, 0}, include_empty: true) == %{
             {-1, -1} => nil,
             {0, -1} => nil,
             {1, -1} => nil,
             {-1, 0} => nil,
             {1, 0} => "b",
             {-1, 1} => nil,
             {1, 1} => "e",
             {0, 1} => "d"
           }
  end
end
