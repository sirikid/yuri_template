defmodule YuriTemplate.FragmentExpander do
  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        acc = ["#" | acc]

        case value do
          [{k, v} | kvs] ->
            expand_kvlist(acc, var, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v when is_binary(v) ->
            [String.slice(encode(v), 0, length)|acc]
        end
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [{:explode, var} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, var)

      {:ok, value} ->
        acc = ["#" | acc]

        case value do
          [{k, v} | kvs] ->
            expand_kvlist(acc, var, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v ->
            [encode(v)|acc]
        end
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
            expand_kvlist(acc, var, ?,, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

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

      {:ok, [{k, v}|kvs]} ->
        expand_kvlist([","|acc], var, k, v, kvs)

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

      {:ok, value} ->
        acc = ["," | acc]

        case value do
          [{k, v} | kvs] ->
            expand_kvlist(acc, var, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v ->
            [encode(v) | acc]
        end
    end
    |> continue_expand(substitutes, vars)
  end

  @spec expand_kvlist(iodata, atom, ?, | ?=, String.t(), String.t(), [{String.t(), String.t()}]) ::
          iodata
  defp expand_kvlist(acc, _var, kvdel \\ ?=, k, v, kvs) do
    for {k, v} <- kvs, reduce: [v, kvdel, k | acc] do
      acc -> [v, kvdel, k, ?, | acc]
    end
  end

  @spec expand_list(iodata, atom, String.t(), [String.t()]) :: iodata
  defp expand_list(acc, _var, v, vs) do
    for v <- vs, reduce: [encode(v) | acc] do
      acc -> [encode(v), "," | acc]
    end
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unescaped?/1)
end
