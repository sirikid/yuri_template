defmodule YuriTemplate.FragmentExpander do
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
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [encode(v), "=", k, "#" | acc],
              fn {k, v}, acc -> [encode(v), "=", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(vs, [encode(v), "#" | acc], &[encode(&1), "," | &2])

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
        [encode(String.slice(v, 0, length)), "#" | acc]
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        acc = ["#" | acc]

        case value do
          [{k, v} | kvs] ->
            Enum.reduce(
              kvs,
              [encode(v), ",", k | acc],
              fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
            )

          [v | vs] ->
            Enum.reduce(vs, [encode(v) | acc], &[encode(&1), "," | &2])

          [] ->
            acc

          v ->
            [encode(v) | acc]
        end
        |> continue_expand(substitutes, vars)
    end
  end

  @spec continue_expand(iodata, Access.t(), YuriTemplate.Expander.spec()) :: iodata
  defp continue_expand(acc, _substitutes, []), do: acc

  defp continue_expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        Enum.reduce(
          kvs,
          acc,
          fn {k, v}, acc -> [encode(v), "=", k, "," | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        Enum.reduce(vs, acc, &[encode(&1), "," | &2])
    end
    |> continue_expand(substitutes, vars)
  end

  defp continue_expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        [encode(String.slice(v, 0, length)), "," | acc]
    end
    |> continue_expand(substitutes, vars)
  end

  defp continue_expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{_k, _v} | _] = kvs} ->
        Enum.reduce(
          kvs,
          acc,
          fn {k, v}, acc -> [encode(v), ",", k, "," | acc] end
        )

      {:ok, vs} when is_list(vs) ->
        Enum.reduce(vs, acc, &[encode(&1), "," | &2])

      {:ok, v} when is_binary(v) ->
        [encode(v), "," | acc]
    end
    |> continue_expand(substitutes, vars)
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unescaped?/1)
end
