defmodule YuriTemplate.Parsec do
  @moduledoc ""

  import NimbleParsec
  alias YuriTemplate, as: YT

  @doc """
  Full RFC6570 support.
  All operators allowed (no op, levels 2, 3 and reserved).
  """
  @spec rfc6570 :: NimbleParsec.t()
  def rfc6570 do
    repeat(
      choice([
        literal(),
        expansion("", YT.SimpleExpander),
        # op-level2
        expansion("+", YT.ReservedExpander),
        expansion("#", YT.FragmentExpander),
        # op-level3
        expansion(".", YT.LabelExpander),
        expansion("/", YT.PathExpander),
        expansion(";", YT.ParameterExpander),
        expansion("?", YT.QueryExpander),
        expansion("&", YT.QueryContinuationExpander),
        # op-reserve
        expansion("=", YT.UndefinedExpander),
        expansion(",", YT.UndefinedExpander),
        expansion("!", YT.UndefinedExpander),
        expansion("@", YT.UndefinedExpander),
        expansion("|", YT.UndefinedExpander)
      ])
    )
  end

  @doc """
  Restricted RFC6570, only meaningful operators allowed.
  """
  @spec rfc6570_restricted :: NimbleParsec.t()
  def rfc6570_restricted do
    repeat(
      choice([
        literal(),
        expansion("", YT.SimpleExpander),
        # op-level2
        expansion("+", YT.ReservedExpander),
        expansion("#", YT.FragmentExpander),
        # op-level3
        expansion(".", YT.LabelExpander),
        expansion("/", YT.PathExpander),
        expansion(";", YT.ParameterExpander),
        expansion("?", YT.QueryExpander),
        expansion("&", YT.QueryContinuationExpander)
      ])
    )
  end

  @spec literal(NimbleParsec.t()) :: NimbleParsec.t()
  def literal(prev \\ empty()) do
    prev
    |> ascii_string([not: ?{, not: ?}], min: 1)
    |> label("literal")
  end

  @spec expansion(NimbleParsec.t(), String.t(), YuriTemplate.Expander.t()) :: NimbleParsec.t()
  def expansion(prev \\ empty(), prefix, expander) do
    prev
    |> ignore(string("{"))
    |> ignore(string(prefix))
    |> variable_list()
    |> ignore(string("}"))
    |> tag(expander)
    |> label("expansion (prefix = #{inspect(prefix)})")
  end

  @spec variable_list(NimbleParsec.t()) :: NimbleParsec.t()
  def variable_list(prev \\ empty()) do
    prev
    |> varspec()
    |> repeat(ignore(string(",")) |> varspec())
    |> label("variable list")
  end

  @spec varspec(NimbleParsec.t()) :: NimbleParsec.t()
  def varspec(prev \\ empty()) do
    prev
    |> choice([
      varname()
      |> ignore(string("*"))
      |> map({__MODULE__, :varspec_explode, []}),
      varname()
      |> ignore(string(":"))
      |> integer(min: 1, max: 5)
      |> wrap()
      |> map({__MODULE__, :varspec_truncate, []}),
      varname()
    ])
    |> label("varspec")
  end

  @doc false
  def varspec_explode(varname) do
    {:explode, varname}
  end

  @doc false
  def varspec_truncate([varname, max_length]) do
    {:prefix, varname, max_length}
  end

  @spec varname(NimbleParsec.t()) :: NimbleParsec.t()
  def varname(prev \\ empty()) do
    prev
    |> varchar()
    |> repeat(optional(string(".")) |> varchar())
    |> wrap()
    |> map({Enum, :join, []})
    |> label("varname")
  end

  @spec varchar(NimbleParsec.t()) :: NimbleParsec.t()
  def varchar(prev \\ empty()) do
    prev
    |> choice([
      ascii_char([?a..?z, ?A..?Z, ?0..?9, ?_]),
      percent_encoded()
    ])
    |> wrap()
    |> map({IO, :iodata_to_binary, []})
    |> label("varchar")
  end

  @spec percent_encoded(NimbleParsec.t()) :: NimbleParsec.t()
  def percent_encoded(prev \\ empty()) do
    prev
    |> ignore(string("%"))
    |> ascii_string([?a..?f, ?A..?F, ?0..?9], 2)
    |> map({String, :to_integer, [16]})
    |> wrap()
    |> map({IO, :iodata_to_binary, []})
    |> label("percent encoded")
  end
end
