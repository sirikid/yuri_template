defmodule YuriTemplate.UnsafeExpander do
  @moduledoc """
  This expander does not encode values in any way, thus it can form an
  incorrect URI.
  """

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(acc, _substitutes, []), do: acc

  def expand(acc, substitutes, [var | vars]) do
    case Access.fetch(substitutes, var) do
      :error ->
        acc

      {:ok, v} when is_binary(v) ->
        [v | acc]
    end
    |> expand(substitutes, vars)
  end
end
