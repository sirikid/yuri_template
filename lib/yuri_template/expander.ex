defmodule YuriTemplate.Expander do
  @type spec :: [atom | {:explode, atom} | {:prefix, atom, 1..10_000}]

  @callback expand(iodata, Access.t(), spec) :: iodata
end
