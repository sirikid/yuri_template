defmodule YuriTemplate.UndefinedExpanderTest do
  use ExUnit.Case

  describe "expand" do
    assert_raise YuriTemplate.UndefinedExpanderError, fn ->
      YuriTemplate.UndefinedExpander.expand(nil, nil, nil)
    end
  end
end
