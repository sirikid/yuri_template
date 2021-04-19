defmodule YuriTemplate.ParsecTest.TestParsers do
  import NimbleParsec
  import YuriTemplate.Parsec

  defparsec(:parse_percent_encoded, percent_encoded())

  defparsec(:parse_varchar, varchar())

  defparsec(:parse_varname, varname())

  defparsec(:parse_varspec, varspec())

  defparsec(:parse_variable_list, variable_list())

  defparsec(:parse_expansion, expansion("~w~", :parsec_test))

  defparsec(:parse_literal, literal())
end

defmodule YuriTemplate.ParsecTest do
  use ExUnit.Case
  import YuriTemplate.ParsecTest.TestParsers

  describe "percent_encoded" do
    assert match?({:ok, ["!"], "", _, _, _}, parse_percent_encoded("%21"))
    assert match?({:ok, ["*"], "", _, _, _}, parse_percent_encoded("%2a"))
    assert match?({:ok, ["*"], "", _, _, _}, parse_percent_encoded("%2A"))

    assert match?({:error, _, _, _, _, _}, parse_percent_encoded("%"))
    assert match?({:error, _, _, _, _, _}, parse_percent_encoded("%2"))
    assert match?({:error, _, _, _, _, _}, parse_percent_encoded("%z"))
    assert match?({:error, _, _, _, _, _}, parse_percent_encoded("%2z"))
  end

  describe "varchar" do
    assert match?({:ok, ["a"], "", _, _, _}, parse_varchar("a"))
    assert match?({:ok, ["1"], "", _, _, _}, parse_varchar("1"))
    assert match?({:ok, ["_"], "", _, _, _}, parse_varchar("_"))
  end

  describe "varname" do
    assert match?({:ok, ["foo"], "", _, _, _}, parse_varname("foo"))
    assert match?({:ok, ["f.o"], "", _, _, _}, parse_varname("f.o"))

    assert match?({:error, _, _, _, _, _}, parse_varname("."))
    # assert match?({:error, _}, parse_varname("f."))
    # assert match?({:error, _}, parse_varname("f..o"))
  end

  describe "varspec" do
    assert match?({:ok, ["foo"], "", _, _, _}, parse_varspec("foo"))
    assert match?({:ok, [{:explode, "foo"}], "", _, _, _}, parse_varspec("foo*"))
    assert match?({:ok, [{:prefix, "foo", 13}], "", _, _, _}, parse_varspec("foo:13"))
  end

  describe "variable_list" do
    assert match?(
             {:ok, ["foo", {:explode, "bar"}, {:prefix, "baz", 27}, "qux"], "", _, _, _},
             parse_variable_list("foo,bar*,baz:27,qux")
           )
  end

  describe "expansion" do
    assert match?(
             {:ok, [{:parsec_test, ["qwe"]}], "", _, _, _},
             parse_expansion("{~w~qwe}")
           )

    assert match?(
             {:error, _, _, _, _, _},
             parse_expansion("{x_xqwe}")
           )
  end

  describe "literal" do
    assert match?(
             {:ok, ["hello, world!"], "", _, _, _},
             parse_literal("hello, world!")
           )
  end
end
