defmodule YuriTemplate do
  alias YuriTemplate.RFC6570

  @spec parse(String.t()) :: {:ok, RFC6570.t} | {:error, term}
  defdelegate parse(str), to: RFC6570

  @spec expand(String.t | RFC6570.t, Access.t) :: {:ok, String.t()} | {:error, term}
  def expand(str, substitutes) when is_binary(str) do
    with {:ok, template} <- parse(str) do
      expand(template, substitutes)
    end
  end

  def expand(template, substitutes) do
    {:ok, IO.iodata_to_binary(RFC6570.expand(template, substitutes))}
  end

  @spec expand!(String.t | RFC6570.t, Access.t) :: String.t
  def expand!(str, substitutes) when is_binary(str) do
    case parse(str) do
      {:ok, template} ->
        template
        |> RFC6570.expand(substitutes)
        |> IO.iodata_to_binary()
      {:error, reason} ->
        raise RuntimeError, message: inspect(reason)
    end
  end

  def expand!(template, substitutes) do
    RFC6570.expand(template, substitutes)
  end
end
