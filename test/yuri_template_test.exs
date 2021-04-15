defmodule YuriTemplateTest do
  use ExUnit.Case

  test "parse/1 #1" do
    assert match?({:ok, _}, YuriTemplate.parse("a string"))
  end

  test "parse/1 #2" do
    assert match?({:ok, _}, YuriTemplate.parse("correct {template}"))
  end

  test "parse/1 #3" do
    assert match?({:error, _}, YuriTemplate.parse("incorrect template {"))
  end

  test "expand/2 #1" do
    assert match?({:ok, _}, YuriTemplate.expand("a string", []))
  end

  test "expand/2 #2" do
    assert match?({:ok, _}, YuriTemplate.expand("correct {template}", []))
  end

  test "expand/2 #3" do
    assert match?({:error, _}, YuriTemplate.expand("incorrect template {", []))
  end

  test "expand!/2 #1" do
    assert match?(_, YuriTemplate.expand!("a string", []))
  end

  test "expand!/2 #2" do
    assert match?(_, YuriTemplate.expand!("correct {template}", []))
  end

  test "expand!/2 #3" do
    assert_raise YuriTemplate.ParseError, fn ->
      YuriTemplate.expand!("incorrect template {", [])
    end
  end

  test "expand!/2 #4" do
    {:ok, template} = YuriTemplate.RFC6570.parse("{.x,y,z}")
    assert match?(_, YuriTemplate.expand!(template, []))
  end

  test "parameters/1 #1" do
    {:ok, template} = YuriTemplate.parse("{foo,bar*,baz:10}")
    assert [:foo, :bar, :baz] == YuriTemplate.parameters(template)
  end

  test "parameters/1 #2" do
    {:ok, template} = YuriTemplate.parse("http://example.com/people/{first_name}-{last_name}")
    assert [:first_name, :last_name] == YuriTemplate.parameters(template)
  end
end
