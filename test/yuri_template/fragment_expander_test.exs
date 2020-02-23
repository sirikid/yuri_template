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
end
