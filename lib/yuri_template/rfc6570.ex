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

  require NimbleParsec
  NimbleParsec.defparsec(:parse1, YuriTemplate.Parsec.uri_template())

  @doc """
  Parses the given string to the `t:t/0`.
  """
  @spec parse(String.t()) :: {:ok, t} | {:error, term}
  def parse(str) do
    alias YuriTemplate.ParseError

    case parse1(str) do
      {:ok, acc, "", _context, _position, _offset} ->
        {:ok, acc}

      {:ok, _acc, rest, context, position, offset} ->
        {:error, ParseError.new("expected end of string", rest, context, position, offset)}

      {:error, reason, rest, context, position, offset} ->
        {:error, ParseError.new(inspect(reason), rest, context, position, offset)}
    end
  end

  @doc """
  Expands the template using given substitutes into an `t:iodata/0`.
  """
  @spec expand(t, Access.t()) :: iodata
  def expand(template, substitutes) do
    []
    |> expand_acc(template, substitutes)
    |> Enum.reverse()
  end

  @spec expand_acc([iodata], t, Access.t()) :: [iodata]
  defp expand_acc(acc, template, substitutes) do
    case template do
      nil ->
        acc

      [] ->
        acc

      [literal | template] when is_binary(literal) ->
        expand_acc([literal | acc], template, substitutes)

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
      _op -> YT.SimpleExpander
    end
    |> apply(:expand, [acc, substitutes, varlist])
  end
end
