defmodule YuriTemplate.UnsafeExpanderTest do
  use ExUnit.Case

  alias YuriTemplate.UnsafeExpander, as: UE

  describe "expand/3" do
    test "no variables left" do
      assert UE.expand("an accumulator", nil, []) == "an accumulator"
    end

    test "non existing variable" do
      assert UE.expand("another accumulator", [], [:undef]) == "another accumulator"
    end

    test "existing variable" do
      expected = ["https://example.org" | "accumulator"]
      actual = UE.expand("accumulator", [var: "https://example.org"], [:var])

      assert actual == expected
    end
  end
end
