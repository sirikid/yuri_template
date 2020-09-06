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
        [encode(v) |> String.slice(0, length), "." | acc]
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
          fn {k, v}, acc -> [encode(v), "=", k, "." | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        Enum.reduce(vs, acc, &[encode(&1), "." | &2])
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
              [encode(v), ",", k, "." | acc],
              fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [encode(v), "." | acc],
              &[encode(&1), "," | &2]
            )

          [] ->
            acc

          v ->
            [encode(v), "." | acc]
        end
    end
    |> expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
