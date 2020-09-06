defmodule YuriTemplate.QueryExpander do
  @moduledoc false

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, v} when is_binary(v) ->
        [String.slice(encode(v), 0, length), "=", to_string(var), "?" | acc]
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        case value do
          [{k1, v1} | kvs] ->
            Enum.reduce(
              kvs,
              [encode(v1), "=", k1, "?" | acc],
              fn {k, v}, acc -> [encode(v), "=", k, "&" | acc] end
            )

          [v1 | vs] ->
            k = to_string(var)

            Enum.reduce(
              vs,
              [encode(v1), "=", k, "?" | acc],
              &[encode(&1), "=", k, "&" | &2]
            )
        end
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        case value do
          [{k1, v1} | kvs] ->
            Enum.reduce(
              kvs,
              [encode(v1), ",", k1, "=", to_string(var), "?" | acc],
              fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [encode(v), "=", to_string(var), "?" | acc],
              &[encode(&1), "," | &2]
            )

          [] ->
            acc

          v ->
            [encode(v), "=", to_string(var), "?" | acc]
        end
        |> continue_expand(substitutes, vars)
    end
  end

  @spec continue_expand(iodata, Access.t(), YuriTemplate.Expander.spec()) :: iodata
  def continue_expand(acc, substitutes, vars) do
    YuriTemplate.QueryContinuationExpander.expand(acc, substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unreserved?/1)
end
