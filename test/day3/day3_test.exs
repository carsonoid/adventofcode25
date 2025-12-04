defmodule Day3Part2Test do
  use ExUnit.Case
  doctest Day3Part2

  test "resolve case 1" do
    assert Day3Part2.solve_line("987654321111111") == 987_654_321_111
  end

  test "resolve case 2" do
    assert Day3Part2.solve_line("811111111111119") == 811_111_111_119
  end

  test "resolve case 3" do
    assert Day3Part2.solve_line("234234234234278") == 434_234_234_278
  end

  test "resolve case 4" do
    assert Day3Part2.solve_line("818181911112111") == 888_911_112_111
  end
end
