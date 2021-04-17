defmodule YuriTemplate.Parsec do
  @moduledoc false

  import NimbleParsec

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

  def varspec_explode(varname) do
    {:explode, varname}
  end

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

  def literal do
    ascii_string([not: ?{, not: ?}], min: 1)
    |> label("literal")
  end

  def rfc6570 do
    alias YuriTemplate, as: YT

    repeat(
      choice([
        literal(),
        expansion("", YT.SimpleExpander),
        expansion("+", YT.ReservedExpander),
        expansion("#", YT.FragmentExpander),
        expansion(".", YT.LabelExpander),
        expansion("/", YT.PathExpander),
        expansion(";", YT.ParameterExpander),
        expansion("?", YT.QueryExpander),
        expansion("&", YT.QueryContinuationExpander)
      ])
    )
  end

  def operator_level_2(prev \\ empty()), do: prev |> choice(Enum.map('+#', &ascii_char([&1])))

  def operator_level_3(prev \\ empty()),
    do: prev |> choice(Enum.map('./;?&', &ascii_char([&1])))

  def operator_level_reserve(prev \\ empty()),
    do: prev |> choice(Enum.map('=,!@|', &ascii_char([&1])))

  def operator(prev \\ empty()) do
    prev
    |> choice([
      operator_level_2(),
      operator_level_3(),
      operator_level_reserve()
    ])
  end

  def max_length, do: integer(min: 1, max: 5)

  def prefix(prev \\ empty()) do
    prev
    |> ignore(ascii_char([?:]))
    |> concat(max_length())
  end

  def explode(prev \\ empty()) do
    prev
    |> ignore(ascii_char([?*]))
  end

  def modifier_level4, do: choice([prefix(), explode()])
end
