defmodule Day9Part2 do
  defmodule RC do
    def comb(_, 0), do: [[]]
    def comb([], _), do: []

    def comb([h | t], m) do
      for(l <- comb(t, m - 1), do: [h | l]) ++ comb(t, m)
    end
  end

  def get_corners({x1, y1}, {x2, y2}) do
    max_x = max(x1, x2)
    max_y = max(y1, y2)
    min_x = min(x1, x2)
    min_y = min(y1, y2)

    {
      # top left
      {min_x, min_y},
      # top right
      {max_x, min_y},
      # bottom left
      {min_x, max_y},
      # bottom right
      {max_x, max_y}
    }
  end

  def get_lines(points) do
    {_, v_lines, h_lines} =
      (points ++ [hd(points)])
      |> Enum.reduce({{-1, -1}, [], []}, fn {_x1, y1} = cur,
                                            {{_x2, y2} = prev, v_lines, h_lines} ->
        if y2 == -1 do
          {cur, v_lines, h_lines}
        else
          if y1 == y2 do
            # horizontal
            {
              cur,
              v_lines,
              [{cur, prev} | h_lines]
            }
          else
            # vertical
            {
              cur,
              [{cur, prev} | v_lines],
              h_lines
            }
          end
        end
      end)

    {v_lines, h_lines}
  end

  defp vertical_lines_bisect?(
         v_lines,
         {top_left, top_right, bottom_left, _bottom_right}
       ) do
    Enum.any?(v_lines, fn {{x, y1}, {_, y2}} ->
      # line x must be strictly inside the rectangle (not on edges)
      x_inside = x > elem(top_left, 0) and x < elem(top_right, 0)

      # For a vertical line to bisect the rectangle, it must cross through it
      # This means the line's y range must overlap with the rectangle's y range
      line_min_y = min(y1, y2)
      line_max_y = max(y1, y2)
      rect_min_y = elem(top_left, 1)
      rect_max_y = elem(bottom_left, 1)

      # Check if line crosses through the rectangle vertically
      line_crosses_rect = line_min_y < rect_max_y and line_max_y > rect_min_y

      x_inside and line_crosses_rect
    end)
  end

  defp horizontal_lines_bisect?(
         h_lines,
         {top_left, top_right, _bottom_left, bottom_right}
       ) do
    Enum.any?(h_lines, fn {{x1, y}, {x2, _}} ->
      # line y must be strictly inside the rectangle (not on edges)
      y_inside = y > elem(top_left, 1) and y < elem(bottom_right, 1)

      # For a horizontal line to bisect the rectangle, it must cross through it
      # This means the line's x range must overlap with the rectangle's x range
      line_min_x = min(x1, x2)
      line_max_x = max(x1, x2)
      rect_min_x = elem(top_left, 0)
      rect_max_x = elem(top_right, 0)

      # Check if line crosses through the rectangle horizontally
      line_crosses_rect = line_min_x < rect_max_x and line_max_x > rect_min_x

      y_inside and line_crosses_rect
    end)
  end

  def get_area({x1, y1}, {x2, y2}) do
    max_x = max(x1, x2)
    max_y = max(y1, y2)
    min_x = min(x1, x2)
    min_y = min(y1, y2)

    (max_x - min_x + 1) * (max_y - min_y + 1)
  end

  def draw(points, h_lines, v_lines) do
    grid = Grid.new(15, 9)

    points
    |> Enum.reduce(grid, fn p, grid ->
      Grid.update(grid, p, "#")
    end)
    |> Grid.inspect()

    grid =
      h_lines
      |> Enum.reduce(grid, fn {{x1, y}, {x2, _}}, grid ->
        min(x1, x2)..max(x1, x2)
        |> Enum.reduce(grid, fn x, grid ->
          Grid.update(grid, {x, y}, "X")
        end)
      end)
      |> Grid.inspect()

    v_lines
    |> Enum.reduce(grid, fn {{x, y1}, {_, y2}}, grid ->
      min(y1, y2)..max(y1, y2)
      |> Enum.reduce(grid, fn y, grid ->
        Grid.update(grid, {x, y}, "X")
      end)
    end)
    |> Grid.inspect()
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    IO.inspect(lines)

    points =
      lines
      |> Enum.map(fn line ->
        line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)

    # get a list of lines between each point and the one above and below it
    {v_lines, h_lines} = get_lines(points)

    IO.inspect(v_lines, label: :v_lines) |> Enum.count() |> IO.inspect(label: :v_lines_count)
    IO.inspect(h_lines, label: :h_lines) |> Enum.count() |> IO.inspect(label: :h_lines_count)

    IO.puts("")

    # vertical_lines_bisect?(
    #   [{{7, 0}, {7, 1}}],
    #   get_corners({2, 5}, {11, 1})
    # )
    # |> IO.inspect(label: :testing)

    points
    |> RC.comb(2)
    |> IO.inspect()
    |> Enum.reject(fn [p1, p2] ->
      # the only valid rectangles are the ones inside the shape
      # we know they are in the shape if there are no vertical or horizontal
      # lines that pass through them, not including lines along the edge of them
      corners = get_corners(p1, p2)

      vertical_lines_bisect?(v_lines, corners) or
        horizontal_lines_bisect?(h_lines, corners)
    end)
    |> Enum.map(fn [p1, p2] ->
      get_area(p1, p2)
    end)
    |> Enum.max()
    |> IO.inspect()
  end
end
