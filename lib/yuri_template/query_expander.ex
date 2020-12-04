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
        v = String.slice(v, 0, length)

        [acc, "?", to_string(var), "=", encode(v)]
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
              [acc, "?", k1, "=", encode(v1)],
              fn {k, v}, acc -> [acc, "&", k, "=", encode(v)] end
            )

          [v1 | vs] ->
            k = to_string(var)

            Enum.reduce(
              vs,
              [acc, "?", k, "=", encode(v1)],
              &[&2, "&", k, "=", encode(&1)]
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
              [acc, "?", to_string(var), "=", k1, ",", encode(v1)],
              fn {k, v}, acc -> [acc, ",", k, ",", encode(v)] end
            )

          [v | vs] ->
            Enum.reduce(
              vs,
              [acc, "?", to_string(var), "=", encode(v)],
              &[&2, ",", encode(&1)]
            )

          [] ->
            acc

          v ->
            [acc, "?", to_string(var), "=", encode(v)]
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
