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
        [acc, ";", to_string(var), "=", String.slice(v, 0, length)]
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
          fn {k, v}, acc -> [acc, ";", k, "=", encode(v)] end
        )

      {:ok, vs} when is_list(vs) ->
        k = to_string(var)

        Enum.reduce(
          vs,
          acc,
          fn v, acc -> [acc, ";", k, "=", encode(v)] end
        )
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, ""} ->
        [acc, ";", to_string(var)]

      {:ok, <<v::binary>>} when is_binary(v) ->
        [acc, ";", to_string(var), "=", encode(v)]

      {:ok, [{k, v} | kvs]} ->
        Enum.reduce(
          kvs,
          [acc, ";", to_string(var), "=", k, ",", encode(v)],
          fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
        )

      {:ok, [v | vs]} ->
        Enum.reduce(
          vs,
          [acc, ";", to_string(var), "=", encode(v)],
          fn v, acc -> [acc, ",", encode(v)] end
        )
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
