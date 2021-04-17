defmodule YuriTemplate.RFC6570 do
  @moduledoc """
  This module contains RFC6570-specific functions.
  """

  @typedoc """
  Internal template representation. Subject to change at any time
  without prior notice.
  """
  @opaque t :: [String.t() | {module, varlist}]

  @typep varlist :: [varspec]

  @typep varspec :: atom | {:explode, atom} | {:prefix, atom, 1..10_000}

  @type name_conv :: :binary | :atom | :existing_atom | [atom]

  require NimbleParsec
  NimbleParsec.defparsec(:parse1, YuriTemplate.Parsec.rfc6570())

  @doc """
  Parses the given string to the `t:t/0`.

  Second argument describes how to convert variable names.
  - `:atom` - default, potentially unsafe. Names converted using
    `String.to_atom/1`.
  - `:binary` - no conversion, safe option.
  - `:existring_atom` or any list - more safe alternative to `:atom`,
    names converted using `String.to_existing_atom/1`. You can use
    list of atoms instead of `:existing_atom` to ensure that all atoms
    you need already exist.
  """
  @spec parse(String.t(), name_conv) :: {:ok, t} | {:error, term}
  def parse(str, _name_conv \\ :atom) do
    alias YuriTemplate.ParseError

    case parse1(str) do
      {:ok, acc, "", _context, _position, _offset} ->
        {:ok, acc}

      {:ok, _acc, "{" <> rest, context, position, offset} ->
        {:error, ParseError.new("unterminated expression", rest, context, position, offset)}

      {:ok, _acc, rest, context, position, offset} ->
        {:error, ParseError.new("expected end of string", rest, context, position, offset)}

        # {:error, reason, rest, context, position, offset} ->
        #   {:error, ParseError.new(inspect(reason), rest, context, position, offset)}
    end
  end

  @doc "Return all variables from the template."
  @spec parameters(t()) :: [atom] | [String.t()]
  def parameters(template) do
    template
    |> Enum.flat_map(fn
      lit when is_binary(lit) -> []
      {_expander, vars} -> vars
    end)
    |> Enum.map(fn
      {:explode, var} -> var
      {:prefix, var, _length} -> var
      var -> var
    end)
    |> Enum.uniq()
  end

  @doc """
  Expands the template using given substitutes into an `t:iodata/0`.
  """
  @spec expand(t, Access.t()) :: iodata
  def expand(template, substitutes) do
    expand_acc([], template, substitutes)
  end

  @spec expand_acc(iodata, t, Access.t()) :: iodata
  defp expand_acc(acc, template, substitutes) do
    case template do
      nil ->
        acc

      [] ->
        acc

      [literal | template] when is_binary(literal) ->
        [acc, literal]
        |> expand_acc(template, substitutes)

      [{expander, varlist} | template] ->
        acc
        |> expander.expand(substitutes, varlist)
        |> expand_acc(template, substitutes)
    end
  end
end
