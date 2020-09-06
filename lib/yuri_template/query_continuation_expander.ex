defmodule YuriTemplate.QueryContinuationExpander do
  @moduledoc false

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        Enum.reduce(
          kvs,
          acc,
          fn {k, v}, acc -> [encode(v), "=", k, "&" | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)
        Enum.reduce(vs, acc, &[encode(&1), "=", k, "&" | &2])
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        # FIXME: add test for missing encode/1
        [String.slice(v, 0, length), "=", to_string(var), "&" | acc]
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{k1, v1} | kvs]} ->
        Enum.reduce(
          kvs,
          [encode(v1), ",", k1, "=", to_string(var), "&" | acc],
          fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
        )

      {:ok, [v1 | vs]} ->
        Enum.reduce(
          vs,
          [encode(v1), "=", to_string(var), "&" | acc],
          &[encode(&1), "," | &2]
        )

      {:ok, []} ->
        acc

      {:ok, v} when is_binary(v) ->
        [encode(v), "=", to_string(var), "&" | acc]
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
