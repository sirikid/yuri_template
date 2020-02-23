defmodule YuriTemplate.ParameterExpander do
  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        [v |> String.slice(0, length), "=", to_string(var), ";" | acc]
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        for {k, v} <- kvs, reduce: acc do
          acc -> [encode(v), "=", k, ";" | acc]
        end

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)

        for v <- vs, reduce: acc do
          acc -> [encode(v), "=", k, ";" | acc]
        end
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, ""} ->
        [to_string(var), ";" | acc]

      {:ok, [{k, v} | kvs]} ->
        for {k, v} <- kvs, reduce: [encode(v), ",", k, "=", to_string(var), ";" | acc] do
          acc -> [encode(v), ",", k, "," | acc]
        end

      {:ok, [v | vs]} ->
        for v <- vs, reduce: [encode(v), "=", to_string(var), ";" | acc] do
          acc -> [encode(v), "," | acc]
        end

      {:ok, v} ->
        [encode(v), "=", to_string(var), ";" | acc]
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  def encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
