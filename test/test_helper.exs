ExUnit.start(colors: [enabled: false])

defmodule ExpanderTest do
  @substitutes [
    count: ["one", "two", "three"],
    dom: ["example", "com"],
    dub: "me/too",
    hello: "Hello World!",
    half: "50%",
    var: "value",
    who: "fred",
    base: "http://example.com/home/",
    path: "/foo/bar",
    list: ["red", "green", "blue"],
    keys: [{"semi", ";"}, {"dot", "."}, {"comma", ","}],
    v: "6",
    x: "1024",
    y: "768",
    empty: "",
    empty_keys: []
  ]

  defmacro __using__(cases: cases) do
    quote do
      use ExUnit.Case

      unquote(
        for {pattern, expected} <- cases do
          quote do
            test "expand #{unquote(pattern)} == #{unquote(expected)}" do
              actual = YuriTemplate.expand!(unquote(pattern), unquote(@substitutes))
              assert actual == unquote(expected)
            end
          end
        end
      )
    end
  end
end
