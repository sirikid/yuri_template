defmodule YuriTemplate.FragmentExpanderTest do
  use ExpanderTest,
    cases: [
      # Cases from RFC
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
      {"{#keys*}", "#semi=;,dot=.,comma=,"},
      # Additional cases for 100% coverage
      {"foo{#undef*}", "foo"},
      {"foo{#empty_keys*}", "foo"},
      {"foo{#undef:1337}", "foo"},
      {"foo{#empty_keys}", "foo#"},
      {"{#var,undef*}", "#value"},
      {"{#var,keys*}", "#value,semi=;,dot=.,comma=,"},
      {"{#var,list*}", "#value,red,green,blue"},
      {"{#var,undef:228}", "#value"},
      {"{#var,hello:5}", "#value,Hello"},
      {"{#var,undef}", "#value"},
      {"{#var,keys}", "#value,semi,;,dot,.,comma,,"},
      {"{#var,list}", "#value,red,green,blue"}
    ]
end
