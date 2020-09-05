defmodule YuriTemplate.ParseError do
  @moduledoc "Exception for `nimble_parsec` errors."

  defexception ~w(message rest context position offset)a

  @typedoc "Line index (one based) and cursor index (zero based)."
  @type position :: {line :: pos_integer, cursor :: non_neg_integer}

  @doc """
  Constructor for `YuriTemplate.ParseError`.

  ## Parameters

  - `message`: the textual representation of the error.

  - `rest`: unparsed fragment of the string.

  - `position`: the position in the string where parsing stopped.

  - `offset`: byte offset of the position.
  """
  @spec new(String.t(), binary, map, position, non_neg_integer) :: Exception.t()
  def new(message, rest, context, position, offset) do
    %__MODULE__{
      message: message,
      rest: rest,
      context: context,
      position: position,
      offset: offset
    }
  end
end
