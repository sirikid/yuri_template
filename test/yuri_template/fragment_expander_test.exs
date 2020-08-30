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
    test "explosion of non existing variable" do
      assert YT.expand!("a{#b*}c", []) == "ac"
    end

    test "explosion of empty list" do
      assert YT.expand!("a{#b*}c", b: []) == "ac"
    end

    test "truncation of non existing variable" do
      assert YT.expand!("a{#b:228}c", []) == "ac"
    end

    test "empty variable" do
      assert YT.expand!("a{#b}c", b: []) == "a#c"
    end
  end

  describe "continue_expand/3" do
    test "explosion of non existing variable" do
      assert YT.expand!("{#a,b*}", a: "xxx") == "#xxx"
    end

    test "explosion of kvlist" do
      assert YT.expand!("{#a,b*}", a: "xxx", b: [{"yyy", "zzz"}]) == "#xxx,yyy=zzz"
    end

    test "explosion of list" do
      assert YT.expand!("{#a,b*}", a: "xxx", b: ~w(yyy zzz)) == "#xxx,yyy,zzz"
    end

    test "truncation of non existing variable" do
      assert YT.expand!("{#a,b:5}", a: "xxx") == "#xxx"
    end

    test "truncation" do
      assert YT.expand!("{#a,b:5}", a: "xxx", b: "lorem ipsum") == "#xxx,lorem"
    end

    test "non existing variable" do
      assert YT.expand!("a{#b,c}", b: "xxx") == "a#xxx"
    end

    test "kvlist" do
      assert YT.expand!("a{#b,c}", b: "xxx", c: [{"yyy", "zzz"}]) == "a#xxx,yyy,zzz"
    end

    test "list" do
      assert YT.expand!("a{#b,c}", b: "xxx", c: ~w(yyy zzz)) == "a#xxx,yyy,zzz"
    end
  end
end
