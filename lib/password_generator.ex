defmodule PasswordGenerator do
  @moduledoc """
  Generates random password based on parameters, Module main function is `generate(options)`.
  """
  @allowed_options [:length, :numbers, :uppercase, :symbols]

  @spec generate(
          atom
          | %{
              :length => non_neg_integer,
              :numbers => boolean(),
              :symbols => boolean(),
              :uppercase => boolean()
            }
        ) :: {:ok, bitstring()} | {:error, bitstring()}
  def generate(options) do
    options
    |> validate_options()
    |> handle_validate_options(options)
  end

  defp validate_options(options) do
    cond do
      !Map.has_key?(options, :length) -> false
      !is_integer(options.length) -> false
      Map.has_key?(options, :numbers) && !is_boolean(options.numbers) -> false
      Map.has_key?(options, :symbols) && !is_boolean(options.symbols) -> false
      Map.has_key?(options, :uppercase) && !is_boolean(options.uppercase) -> false
      Map.keys(options) |> Enum.all?(&(&1 in @allowed_options)) |> Kernel.not() -> false
      true -> true
    end
  end

  defp handle_validate_options(false, _options), do: {:error, "invalid options"}

  defp handle_validate_options(true, options) do
    charset = %{
      symbols: String.codepoints("!@#$%&*()_-=£[]{}:;/\\<>,.?~^"),
      numbers: Enum.map(0..9, &Integer.to_string(&1)),
      lowercase: Enum.map(?a..?z, &<<&1>>),
      uppercase: Enum.map(?A..?Z, &<<&1>>)
    }

    result =
      charset.lowercase
      |> add_charset(options, :numbers, charset.numbers)
      |> add_charset(options, :uppercase, charset.uppercase)
      |> add_charset(options, :symbols, charset.symbols)
      |> Enum.shuffle()
      |> Enum.slice(0, options.length)
      |> Enum.join()

    {:ok, result}
  end

  defp add_charset(currentCharset, options, key, newCharset) do
    cond do
      Map.has_key?(options, key) && options[key] -> currentCharset ++ newCharset
      true -> currentCharset
    end
  end
end
