defmodule YuriTemplate do
  @moduledoc """
  Delegates and convenience wrappers.
  """

  alias YuriTemplate.RFC6570

  @spec parse(String.t()) :: {:ok, RFC6570.t()} | {:error, term}
  defdelegate parse(str), to: RFC6570

  @doc """
  Parses (if necessary) and expands the template.

  ## Parameters

  - `template`: the template for the expansion.

  - `substitutes`: mapping names to values.
  """
  @spec expand(String.t() | RFC6570.t(), Access.t()) :: {:ok, String.t()} | {:error, term}
  def expand(template_or_string, substitutes)

  def expand(str, substitutes) when is_binary(str) do
    with {:ok, template} <- parse(str) do
      {:ok, expand_template(template, substitutes)}
    end
  end

  def expand(template, substitutes) do
    {:ok, expand_template(template, substitutes)}
  end

  @doc "Same as `expand/2`, but raises exception on error."
  @spec expand!(String.t() | RFC6570.t(), Access.t()) :: String.t()
  def expand!(template_or_string, substitutes)

  def expand!(str, substitutes) when is_binary(str) do
    case parse(str) do
      {:ok, template} ->
        expand_template(template, substitutes)

      {:error, %{__exception__: true} = error} ->
        raise error

      {:error, reason} ->
        raise RuntimeError, message: inspect(reason)
    end
  end

  def expand!(template, substitutes) do
    expand_template(template, substitutes)
  end

  @spec expand_template(RFC6570.t(), Access.t()) :: String.t()
  defp expand_template(template, substitutes) do
    template
    |> RFC6570.expand(substitutes)
    |> IO.iodata_to_binary()
  end
end
