defmodule YuriTemplate.SimpleExpanderTest do
  use ExpanderTest,
    cases: [
      # Cases from RFC
      {"{var}", "value"},
      {"{hello}", "Hello%20World%21"},
      {"{half}", "50%25"},
      {"O{empty}X", "OX"},
      {"O{undef}X", "OX"},
      {"{x,y}", "1024,768"},
      {"{x,hello,y}", "1024,Hello%20World%21,768"},
      {"?{x,empty}", "?1024,"},
      {"?{x,undef}", "?1024"},
      {"?{undef,y}", "?768"},
      {"{var:3}", "val"},
      {"{var:30}", "value"},
      {"{list}", "red,green,blue"},
      {"{list*}", "red,green,blue"},
      {"{keys}", "semi,%3B,dot,.,comma,%2C"},
      {"{keys*}", "semi=%3B,dot=.,comma=%2C"},
      # Additional cases for 100% coverage
      {"foo{undef*}", "foo"},
      {"bar{empty_keys*}", "bar"},
      {"baz{undef:10}", "baz"},
      {"qux{empty_keys}", "qux"},
      {"{var,keys}", "value,semi,%3B,dot,.,comma,%2C"},
      {"{var,list}", "value,red,green,blue"},
      # {"{var,empty_keys}", FIXME: Should this be "value," or "value"?}
    ]
end
