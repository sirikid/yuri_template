defmodule YuriTemplate.ReservedExpander do
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
            expand_kvlist(acc, var, ?=, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v ->
            expand_value(acc, var, v)
        end
        |> continue_expand(substitutes, vars)
    end
  end

  def expand(acc, substitutes, [{:prefix, var, length} | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        expand(acc, substitutes, vars)

      {:ok, value} ->
        case value do
          [{k, v} | kvs] ->
            expand_kvlist(acc, var, ?,, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v ->
            expand_value(acc, var, v, length)
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
          [{k, v} | kvs] ->
            expand_kvlist(acc, var, ?,, k, v, kvs)

          [v | vs] ->
            expand_list(acc, var, v, vs)

          [] ->
            acc

          v ->
            expand_value(acc, var, v)
        end
        |> continue_expand(substitutes, vars)
    end
  end

  @spec continue_expand(iodata, Access.t(), YuriTemplate.Expander.spec()) :: iodata
  defp continue_expand(acc, _substitutes, []), do: acc

  defp continue_expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, [{k, v} | kvs]} ->
        expand_kvlist(["," | acc], var, ?,, k, v, kvs)

      {:ok, [v | vs]} ->
        expand_list(["," | acc], var, v, vs)

      {:ok, []} ->
        ["," | acc]

      {:ok, v} ->
        expand_value(["," | acc], var, v)
    end
    |> continue_expand(substitutes, vars)
  end

  @spec expand_kvlist(iodata, atom, ?, | ?=, String.t(), String.t(), [{String.t(), String.t()}]) ::
          iodata
  defp expand_kvlist(acc, _var, kvdel, k, v, kvs) do
    for {k, v} <- kvs, reduce: [v, kvdel, k | acc] do
      acc ->
        [v, kvdel, k, "," | acc]
    end
  end

  @spec expand_list(iodata, atom, String.t(), [String.t()]) :: iodata
  defp expand_list(acc, _var, v, vs) do
    for v <- vs, reduce: [v | acc] do
      acc ->
        [encode(v), "," | acc]
    end
  end

  @spec expand_value(iodata, atom, String.t()) :: iodata
  defp expand_value(acc, _var, v) do
    [encode(v) | acc]
  end

  @spec expand_value(iodata, atom, String.t(), integer) :: iodata
  def expand_value(acc, _var, v, length) do
    [encode(v) |> String.slice(0, length) | acc]
  end

  @spec encode(String.t()) :: String.t()
  defp encode(s), do: URI.encode(s, &URI.char_unescaped?/1)
end
