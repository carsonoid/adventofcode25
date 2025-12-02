defmodule Day1Test do
  use ExUnit.Case
  doctest Day1

  test "move function tests" do
    # Test basic left turn that lands on 0
    assert Day1.move(50, "L", "50") == {0, 1}

    # Test basic left turn that goes past 0
    assert Day1.move(50, "L", "51") == {99, 1}

    # Test basic left turn that goes past 0 then lands on it
    assert Day1.move(50, "L", "150") == {0, 2}

    # Test basic left turn that lands on 1
    assert Day1.move(50, "L", "49") == {1, 0}
  end

  test "right turn tests" do
    # Test basic right turn that doesn't cross boundaries
    assert Day1.move(50, "R", "25") == {75, 0}

    # Test right turn that goes past 99 and wraps to 0
    assert Day1.move(50, "R", "50") == {0, 1}

    # Test right turn that goes past 99
    assert Day1.move(50, "R", "51") == {1, 1}

    # Test right turn with large movement crossing boundary multiple times
    assert Day1.move(50, "R", "150") == {0, 2}

    # Test right turn that lands on 99
    assert Day1.move(50, "R", "49") == {99, 0}

    # Test right turn from position 99 that wraps
    assert Day1.move(99, "R", "1") == {0, 1}
  end
end
