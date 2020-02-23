defmodule YuriTemplateg.LabelExpanderTest do
  use ExpanderTest,
    cases: [
      {"{.who}", ".fred"},
      {"{.who,who}", ".fred.fred"},
      {"{.half,who}", ".50%25.fred"},
      {"www{.dom*}", "www.example.com"},
      {"X{.var}", "X.value"},
      {"X{.empty}", "X."},
      {"X{.undef}", "X"},
      {"X{.var:3}", "X.val"},
      {"X{.list}", "X.red,green,blue"},
      {"X{.list*}", "X.red.green.blue"},
      {"X{.keys}", "X.semi,%3B,dot,.,comma,%2C"},
      {"X{.keys*}", "X.semi=%3B.dot=..comma=%2C"},
      {"X{.empty_keys}", "X"},
      {"X{.empty_keys*}", "X"}
    ]
end
