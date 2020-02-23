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
        for {pattern, expansion} <- cases do
          quote do
            test "expand #{unquote(pattern)} == #{unquote(expansion)}" do
              assert YuriTemplate.expand!(unquote(pattern), unquote(@substitutes)) ==
                       unquote(expansion)
            end
          end
        end
      )
    end
  end
end
