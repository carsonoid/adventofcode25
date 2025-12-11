defmodule Day11Part2 do
  def get_graph(lines) do
    for line <- lines do
      [node, edge_string] = String.split(line, ": ")
      edges = String.split(edge_string, " ")
      {node, edges}
    end
    |> :maps.from_list()
  end

  def dfs(graph, node, depth, count, path) do
    # IO.puts(String.duplicate("  ", depth) <> node)

    case node do
      "out" ->
        # Return the complete path as a single-element list
        [path ++ [node]]

      _ ->
        Stream.flat_map(graph[node], fn next ->
          dfs(graph, next, depth + 1, count, path ++ [node])
        end)
    end
  end

  def dfs_memo(graph, cache, node, dac, fft) do
    cache_key = {node, dac, fft}

    case Map.get(cache, cache_key) do
      cached_result when cached_result != nil ->
        {cached_result, cache}

      nil ->
        {result, updated_cache} =
          case node do
            "out" ->
              result = if dac and fft, do: 1, else: 0
              {result, cache}

            _ ->
              {results, final_cache} =
                Enum.reduce(graph[node], {[], cache}, fn next, {acc_results, acc_cache} ->
                  dac = if node == "dac", do: true, else: dac
                  fft = if node == "fft", do: true, else: fft
                  {result, new_cache} = dfs_memo(graph, acc_cache, next, dac, fft)
                  {[result | acc_results], new_cache}
                end)

              {Enum.sum(results), final_cache}
          end

        final_cache = Map.put(updated_cache, cache_key, result)
        {result, final_cache}
    end
  end

  def solve do
    lines = File.read!(System.argv() |> hd()) |> String.trim() |> String.split("\n")

    graph = get_graph(lines)
    IO.inspect(graph)

    # dfs(graph, "svr", 0, 0, [])
    # |> Stream.filter(&(Enum.member?(&1, "fft") and Enum.member?(&1, "dac")))
    # |> IO.inspect()
    # |> Enum.count()
    # |> IO.inspect(label: :result)

    {result, _final_cache} = dfs_memo(graph, %{}, "svr", false, false)
    IO.inspect(result)
  end
end
