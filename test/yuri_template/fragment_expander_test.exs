defmodule YuriTemplate.FragmentExpanderTest do
  use ExpanderTest,
    cases: [
      {"{#var}", "#value"},
      {"{#hello}", "#Hello%20World!"},
      {"{#half}", "#50%25"},
      {"foo{#empty}", "foo#"},
      {"foo{#undef}", "foo"},
      {"{#x,hello,y}", "#1024,Hello%20World!,768"},
      {"{#path,x}/here", "#/foo/bar,1024/here"},
      {"{#path:6}/here", "#/foo/b/here"},
      {"{#list}", "#red,green,blue"},
      {"{#list*}", "#red,green,blue"},
      {"{#keys}", "#semi,;,dot,.,comma,,"},
      {"{#keys*}", "#semi=;,dot=.,comma=,"}
    ]

  alias YuriTemplate, as: YT

  describe "expand/3" do
    alias YuriTemplate.FragmentExpander, as: FE

    test "unexisting exploded variable" do
      assert FE.expand(["an accumulator"], [], [{:explode, :foo}]) == ["an accumulator"]
    end

    test "empty exploded variable" do
      assert FE.expand(["an accumulator"], [foo: []], [{:explode, :foo}]) == ["an accumulator"]
    end

    test "unexisting truncated variable" do
      assert FE.expand(["an accumulator"], [], [{:prefix, :foo, 1337}]) == ["an accumulator"]
    end

    test "empty variable" do
      assert FE.expand(["an accumulator"], [foo: []], [:foo]) == ["#", "an accumulator"]
    end
  end

  describe "continue_expand/3" do
    test "explosion of second or later non existing variable" do
      assert YT.expand!("{#a,b*}", a: "xxx") == "#xxx"
    end

    test "explosion of second or later kvlist variable" do
      assert YT.expand!("{#a,b*}", a: "xxx", b: [{"yyy", "zzz"}]) == "#xxx,yyy=zzz"
    end

    test "explosion of second or later list variable" do
      assert YT.expand!("{#a,b*}", a: "xxx", b: ~w(yyy zzz)) == "#xxx,yyy,zzz"
    end

    test "truncation of second or later non existing variable" do
      assert YT.expand!("{#a,b:5}", a: "xxx") == "#xxx"
    end

    test "truncation of second or later variable" do
      assert YT.expand!("{#a,b:5}", a: "xxx", b: "lorem ipsum") == "#xxx,lorem"
    end
  end
end
