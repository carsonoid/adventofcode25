defmodule Day11Part1 do
  def get_graph(lines) do
    for line <- lines do
      [node, edge_string] = String.split(line, ": ")
      edges = String.split(edge_string, " ")
      {node, edges}
    end
    |> :maps.from_list()
  end

  def dfs(graph, node, depth, count) do
    IO.puts(String.duplicate("  ", depth) <> node)

    case node do
      "out" ->
        :out

      _ ->
        Enum.map(graph[node], fn next ->
          dfs(graph, next, depth + 1, count)
        end)
    end
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    graph = get_graph(lines)
    IO.inspect(graph)

    dfs(graph, "you", 0, 0)
    |> List.flatten()
    |> Enum.count()
    |> IO.inspect()
  end
end
