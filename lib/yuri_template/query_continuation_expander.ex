defmodule YuriTemplate.QueryContinuationExpander do
  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        for {k, v} <- kvs, reduce: acc do
          acc -> [encode(v), "=", k, "&" | acc]
        end

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)

        for v <- vs, reduce: acc do
          acc -> [encode(v), "=", k, "&" | acc]
        end
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        [String.slice(v, 0, length), "=", to_string(var), "&" | acc]
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{k1, v1} | kvs]} ->
        for {k, v} <- kvs, reduce: [encode(v1), ",", k1, "=", to_string(var), "&" | acc] do
          acc -> [encode(v), ",", k, "," | acc]
        end

      {:ok, [v1 | vs]} ->
        for v <- vs, reduce: [encode(v1), "=", to_string(var), "&" | acc] do
          acc -> [encode(v), "," | acc]
        end

      {:ok, []} ->
        acc

      {:ok, v} when is_binary(v) ->
        [encode(v), "=", to_string(var), "&" | acc]
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  def encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
