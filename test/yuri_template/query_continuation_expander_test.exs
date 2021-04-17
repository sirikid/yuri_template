defmodule YuriTemplate.QueryContinuationExpanderTest do
  use ExpanderTest,
    cases: [
      {"{&who}", "&who=fred"},
      {"{&half}", "&half=50%25"},
      {"?fixed=yes{&x}", "?fixed=yes&x=1024"},
      {"{&x,y,empty}", "&x=1024&y=768&empty="},
      {"{&x,y,undef}", "&x=1024&y=768"},
      {"{&var:3}", "&var=val"},
      {"{&list}", "&list=red,green,blue"},
      {"{&list*}", "&list=red&list=green&list=blue"},
      {"{&keys}", "&keys=semi,%3B,dot,.,comma,%2C"},
      {"{&keys*}", "&semi=%3B&dot=.&comma=%2C"}
    ]

  describe "expand/3" do
    alias YuriTemplate.QueryContinuationExpander, as: QCE

    test "unexisting exploded variable" do
      assert QCE.expand(["hello"], [], [{:explode, :foo}]) == ["hello"]
    end

    test "unexisting truncated variable" do
      assert QCE.expand(["world"], [], [{:prefix, :bar, 1488}]) == ["world"]
    end

    test "empty variable" do
      assert QCE.expand(["heh mda"], [foo: []], [:foo]) == ["heh mda"]
    end

    alias YuriTemplate, as: YT

    test "truncated variable escaping" do
      assert YT.expand!("{&v:4}", %{"v" => ",.,.xxxx"}) == "&v=%2C.%2C."
    end
  end
end
