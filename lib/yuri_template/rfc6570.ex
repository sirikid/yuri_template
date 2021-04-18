defmodule YuriTemplate.RFC6570 do
  @moduledoc """
  This module contains RFC6570-specific functions.
  """

  @typedoc """
  Internal template representation. Subject to change at any time
  without prior notice.
  """
  @opaque t :: [String.t() | varlist]

  @typep varlist :: [op | varspec]

  @typep op :: ?+ | ?\# | ?. | ?/ | ?; | ?? | ?&
  defguardp is_op(op) when op in '+#?./;?&'

  @typep varspec :: atom | {:explode, atom} | {:prefix, atom, 1..10_000}

  @type name_conv :: :binary | :atom | :existing_atom | [atom]

  require NimbleParsec

  NimbleParsec.defparsecp(
    :parse_binary,
    YuriTemplate.Parsec.uri_template({Function, :identity, []})
  )

  NimbleParsec.defparsecp(:parse_atom, YuriTemplate.Parsec.uri_template({String, :to_atom, []}))

  NimbleParsec.defparsecp(
    :parse_existing_atom,
    YuriTemplate.Parsec.uri_template({String, :to_existing_atom, []})
  )

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
  def parse(str, name_conv \\ :atom) do
    alias YuriTemplate.ParseError

    result =
      case name_conv do
        :binary -> parse_binary(str)
        :atom -> parse_atom(str)
        :existing_atom -> parse_existing_atom(str)
        atoms when is_list(atoms) -> parse_existing_atom(str)
      end

    case result do
      {:ok, acc, "", _context, _position, _offset} ->
        {:ok, acc}

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
      [op | vars] when is_op(op) and is_list(vars) -> vars
      vars when is_list(vars) -> vars
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

      [[op | varlist] | template] when is_op(op) and is_list(varlist) ->
        acc
        |> expand_varlist(op, varlist, substitutes)
        |> expand_acc(template, substitutes)

      [varlist | template] when is_list(varlist) ->
        acc
        |> expand_varlist(nil, varlist, substitutes)
        |> expand_acc(template, substitutes)
    end
  end

  @spec expand_varlist(iodata, op | nil, varlist, Access.t()) :: iodata
  defp expand_varlist(acc, op, varlist, substitutes) do
    alias YuriTemplate, as: YT

    case op do
      nil -> YT.SimpleExpander
      ?\+ -> YT.ReservedExpander
      ?\# -> YT.FragmentExpander
      ?\. -> YT.LabelExpander
      ?\/ -> YT.PathExpander
      ?\; -> YT.ParameterExpander
      ?\? -> YT.QueryExpander
      ?\& -> YT.QueryContinuationExpander
    end
    |> apply(:expand, [acc, substitutes, varlist])
  end
end
