defmodule YuriTemplate.Expander do
  @moduledoc """
  The most common interface for the template expander.
  """

  @typedoc """
  Variable list specification.
  """
  @type spec :: [atom | {:explode, atom} | {:prefix, atom, 1..10_000}]

  @doc """
  Called to add an expansion of the next list of variables to the
  accumulator.

  ## Parameters

  - `accumulator`: iodata, possibly created by previous expanders.

  - `substitutes`: mapping names to values.

  - `variables`: list of names to get from `substitutes`.
  """
  @callback expand(accumulator :: iodata, substitutes :: Access.t(), variables :: spec) :: iodata
end
