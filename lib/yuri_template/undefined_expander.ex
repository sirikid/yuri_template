defmodule YuriTemplate.UndefinedExpander do
  @moduledoc "Dummy expander."

  @behaviour YuriTemplate.Expander

  @impl true
  def expand(_acc, _substitutes, _variables) do
    raise %YuriTemplate.UndefinedExpanderError{}
  end
end
