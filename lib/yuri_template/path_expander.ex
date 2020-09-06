defmodule YuriTemplate.PathExpander do
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
          fn {k, v}, acc -> [encode(v), "=", k, "/" | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        Enum.reduce(vs, acc, &[&1, "/" | &2])
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        v = String.slice(v, 0, length)

        [encode(v), "/" | acc]
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
          [encode(v1), ",", k1, "/" | acc],
          fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
        )

      {:ok, [v1 | vs]} ->
        # FIXME: add test case for missing encode/1
        Enum.reduce(vs, [v1, "/" | acc], &[&1, "," | &2])

      {:ok, []} ->
        acc

      {:ok, v} when is_binary(v) ->
        [encode(v), "/" | acc]
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
