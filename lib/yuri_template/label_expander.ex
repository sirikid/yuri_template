defmodule YuriTemplate.LabelExpander do
  @moduledoc false

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        v = String.slice(v, 0, length)
        [acc, ".", encode(v)]
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, []} ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        Enum.reduce(
          kvs,
          acc,
          fn {k, v}, acc -> [acc, ".", k, "=", encode(v)] end
        )

      {:ok, vs} when is_list(vs) ->
        Enum.reduce(vs, acc, &[&2, ".", encode(&1)])
    end
    |> expand(substitutes, vars)
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, value} ->
        case value do
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [acc, ".", k, ",", encode(v)],
              fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [acc, ".", encode(v)],
              &[&2, ",", encode(&1)]
            )

          [] ->
            acc

          v ->
            [acc, ".", encode(v)]
        end
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
