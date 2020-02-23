defmodule YuriTemplate.SimpleExpander do
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
              [encode(v1), "=", k1 | acc],
              fn {k, v}, acc -> [encode(v), "=", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [encode(v) | acc],
              fn v, acc -> [encode(v), "," | acc] end
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
        [encode(String.slice(v, 0, length)) | acc]
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
              [encode(v), ",", k | acc],
              fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(vs, [v | acc], &[&1, "," | &2])

          [] ->
            acc

          v ->
            [encode(v) | acc]
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
        acc = ["," | acc]

        case value do
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [v, ",", k, "," | acc],
              fn {k, v}, acc -> [v, k | acc] end
            )

          [v | vs] ->
            Enum.reduce(vs, [v | acc], &[&1 | &2])

          [] ->
            acc

          v ->
            [encode(v) | acc]
        end
    end
    |> continue_expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
