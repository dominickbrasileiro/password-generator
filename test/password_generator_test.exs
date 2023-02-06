defmodule PasswordGeneratorTest do
  use ExUnit.Case
  doctest PasswordGenerator

  setup do
    options = %{
      length: 10,
      numbers: false,
      uppercase: false,
      symbols: false
    }

    charset = %{
      symbols: String.codepoints("!@#$%&*()_-=£[]{}:;/\\<>,.?~^"),
      numbers: Enum.map(0..9, &Integer.to_string(&1)),
      lowercase: Enum.map(?a..?z, &<<&1>>),
      uppercase: Enum.map(?A..?Z, &<<&1>>)
    }

    %{
      options: options,
      charset: charset
    }
  end

  test "returns a string", %{options: options} do
    {:ok, result} = PasswordGenerator.generate(options)

    assert is_bitstring(result)
  end

  test "returns error when no length is given" do
    options = %{invalid: false}

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when length is not an integer" do
    options = %{length: "ab"}

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when options values are not booleans" do
    options = %{
      length: 10,
      numbers: "invalid",
      uppercase: "0",
      symbols: "invalid"
    }

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns error when not allowed option is provided" do
    options = %{length: 10, invalid: true}

    assert {:error, _error} = PasswordGenerator.generate(options)
  end

  test "returns generated string with the same length as provided" do
    options = %{length: 5}
    {:ok, result} = PasswordGenerator.generate(options)

    assert 5 == String.length(result)
  end

  test "returns a lowercase string just when only length is provided", %{charset: charset} do
    options = %{length: 5}
    {:ok, result} = PasswordGenerator.generate(options)

    assert String.contains?(result, charset.lowercase)
    refute String.contains?(result, charset.uppercase)
    refute String.contains?(result, charset.numbers)
    refute String.contains?(result, charset.symbols)
  end
end
