defmodule YuriTemplate.SimpleExpander do
  @moduledoc false

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        case value do
          [{k1, v1} | kvs] ->
            Enum.reduce(
              kvs,
              [acc, k1, "=", encode(v1)],
              fn {k, v}, acc -> [acc, ",", k, "=", encode(v)] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [acc, encode(v)],
              fn v, acc -> [acc, ",", encode(v)] end
            )

          [] ->
            acc
        end
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, v} when is_binary(v) ->
        [acc, encode(String.slice(v, 0, length))]
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        case value do
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [acc, k, ",", encode(v)],
              fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
            )

          [v | vs] ->
            Enum.reduce(vs, [acc, v], &[&2, ",", &1])

          [] ->
            acc

          v ->
            [acc, encode(v)]
        end
        |> continue_expand(substitutes, vars)
    end
  end

  @spec continue_expand(iodata, Access.t(), YuriTemplate.Expander.spec()) :: iodata
  defp continue_expand(acc, _substitues, []), do: acc

  defp continue_expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, value} ->
        acc = [acc, ","]

        case value do
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [acc, k, ",", encode(v)],
              fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
            )

          [v | vs] ->
            Enum.reduce(vs, [acc, v], &[&2, ",", &1])

          [] ->
            acc

          v ->
            [acc, encode(v)]
        end
    end
    |> continue_expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
