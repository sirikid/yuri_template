defmodule YuriTemplate.ParameterExpander do
  @moduledoc false

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        [String.slice(v, 0, length), "=", to_string(var), ";" | acc]
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        Enum.reduce(
          kvs,
          acc,
          fn {k, v}, acc -> [encode(v), "=", k, ";" | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)

        Enum.reduce(
          vs,
          acc,
          fn v, acc -> [encode(v), "=", k, ";" | acc] end
        )
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, ""} ->
        [to_string(var), ";" | acc]

      {:ok, <<v::binary>>} when is_binary(v) ->
        [encode(v), "=", to_string(var), ";" | acc]

      {:ok, [{k, v} | kvs]} ->
        Enum.reduce(
          kvs,
          [encode(v), ",", k, "=", to_string(var), ";" | acc],
          fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
        )

      {:ok, [v | vs]} ->
        Enum.reduce(
          vs,
          [encode(v), "=", to_string(var), ";" | acc],
          fn v, acc -> [encode(v), "," | acc] end
        )
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
