defmodule YuriTemplate.Parsec do
  @moduledoc false

  import NimbleParsec

  def literal(prev \\ empty()),
    do: prev |> ascii_string([not: ?{, not: ?}], min: 1)

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

  def varchar(prev \\ empty()) do
    prev
    |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
  end

  def varname(prev \\ empty(), name_conv) do
    prev
    |> varchar()
    |> repeat(varchar(ascii_string([?.], 1)))
    |> wrap()
    |> map({IO, :iodata_to_binary, []})
    |> map(name_conv)
  end

  def varspec(prev \\ empty(), name_conv) do
    prev
    |> choice([
      varname(name_conv) |> prefix() |> wrap() |> map({__MODULE__, :make_prefix, []}),
      varname(name_conv) |> explode() |> unwrap_and_tag(:explode),
      varname(name_conv)
    ])
  end

  def make_prefix([var, length]) do
    {:prefix, var, length}
  end

  def variable_list(prev \\ empty(), name_conv) do
    prev
    |> varspec(name_conv)
    |> repeat(
      ignore(ascii_char([?,]))
      |> varspec(name_conv)
    )
  end

  def expression(prev \\ empty(), name_conv) do
    prev
    |> ignore(ascii_char([?{]))
    |> optional(operator())
    |> concat(variable_list(name_conv))
    |> ignore(ascii_char([?}]))
    |> wrap()
  end

  def uri_template(name_conv), do: repeat(choice([expression(name_conv), literal()]))
end
