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
          fn {k, v}, acc -> [acc, "&", k, "=", encode(v)] end
        )

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)
        Enum.reduce(vs, acc, &[&2, "&", k, "=", encode(&1)])
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        v = String.slice(v, 0, length)
        [acc, "&", to_string(var), "=", encode(v)]
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
          [acc, "&", to_string(var), "=", k1, ",", encode(v1)],
          fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
        )

      {:ok, [v1 | vs]} ->
        Enum.reduce(
          vs,
          [acc, "&", to_string(var), "=", encode(v1)],
          &[&2, ",", encode(&1)]
        )

      {:ok, []} ->
        acc

      {:ok, v} when is_binary(v) ->
        [acc, "&", to_string(var), "=", encode(v)]
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
