defmodule YuriTemplate.ReservedExpanderTest do
  use ExpanderTest,
    cases: [
      # Cases from RFC
      {"{+var}", "value"},
      {"{+hello}", "Hello%20World!"},
      {"{+half}", "50%25"},
      {"{base}index", "http%3A%2F%2Fexample.com%2Fhome%2Findex"},
      {"{+base}index", "http://example.com/home/index"},
      {"O{+empty}X", "OX"},
      {"O{+undef}X", "OX"},
      {"{+path}/here", "/foo/bar/here"},
      {"here?ref={+path}", "here?ref=/foo/bar"},
      {"up{+path}{var}/here", "up/foo/barvalue/here"},
      {"{+x,hello,y}", "1024,Hello%20World!,768"},
      {"{+path,x}/here", "/foo/bar,1024/here"},
      {"{+path:6}/here", "/foo/b/here"},
      {"{+list}", "red,green,blue"},
      {"{+list*}", "red,green,blue"},
      {"{+keys}", "semi,;,dot,.,comma,,"},
      {"{+keys*}", "semi=;,dot=.,comma=,"},
      # Additional cases for 100% coverage
      {"foo{+undef*}", "foo"},
      {"bar{+empty_keys*}", "bar"},
      {"baz{+undef:6}", "baz"},
      {"qux{+empty_keys}", "qux"},
      {"{+var,undef}", "value"},
      {"{+var,keys}", "value,semi,;,dot,.,comma,,"},
      {"{+var,list}", "value,red,green,blue"}
    ]
end
