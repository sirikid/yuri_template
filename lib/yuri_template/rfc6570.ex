defmodule YuriTemplate.RFC6570 do
  @opaque t :: [String.t() | varlist]

  @typep varlist :: [op | varspec]

  @typep op :: ?+ | ?\# | ?. | ?/ | ?; | ?? | ?&
  defguardp is_op(op) when op in '+#?./;?&'

  @typep varspec :: atom | {:explode, atom} | {:prefix, atom, 1..10_000}

  # Expander

  require NimbleParsec
  NimbleParsec.defparsec(:parse1, YuriTemplate.Parsec.uri_template())

  @spec parse(String.t()) :: {:ok, t} | {:error, term}
  def parse(str) do
    case parse1(str) do
      {:ok, template, "", _, _, _} ->
        {:ok, template}

      {:ok, _template, _leftover, _, _, position} ->
        {:error, {:unexpected_character, position}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec expand(iodata, t, Access.t()) :: iodata
  def expand(acc \\ [], template, substitutes) do
    case template do
      nil ->
        Enum.reverse(acc)

      [] ->
        Enum.reverse(acc)

      [literal | template] when is_binary(literal) ->
        expand([literal | acc], template, substitutes)

      [[op | varlist] | template] when is_op(op) and is_list(varlist) ->
        acc
        |> expand_varlist(op, varlist, substitutes)
        |> expand(template, substitutes)

      [varlist | template] when is_list(varlist) ->
        acc
        |> expand_varlist(nil, varlist, substitutes)
        |> expand(template, substitutes)
    end
  end

  @spec expand_varlist(iodata, op | nil, varlist, Access.t()) :: iodata
  defp expand_varlist(acc, op, varlist, substitutes) do
    case op do
      nil -> YuriTemplate.SimpleExpander.expand(acc, substitutes, varlist)
      ?\+ -> YuriTemplate.ReservedExpander.expand(acc, substitutes, varlist)
      ?\# -> YuriTemplate.FragmentExpander.expand(acc, substitutes, varlist)
      ?\. -> YuriTemplate.LabelExpander.expand(acc, substitutes, varlist)
      ?\/ -> YuriTemplate.PathExpander.expand(acc, substitutes, varlist)
      ?\; -> YuriTemplate.ParameterExpander.expand(acc, substitutes, varlist)
      ?\? -> YuriTemplate.QueryExpander.expand(acc, substitutes, varlist)
      ?\& -> YuriTemplate.FormContinuationExpander.expand(acc, substitutes, varlist)
      _op -> YuriTemplate.SimpleExpander.expand(acc, substitutes, varlist)
    end
  end
end
