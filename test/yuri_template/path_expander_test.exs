defmodule YuriTemplate.PathExpanderTest do
  use ExpanderTest,
    cases: [
      # Cases from RFC
      {"{/who}", "/fred"},
      {"{/who,who}", "/fred/fred"},
      {"{/half,who}", "/50%25/fred"},
      {"{/who,dub}", "/fred/me%2Ftoo"},
      {"{/var}", "/value"},
      {"{/var,empty}", "/value/"},
      {"{/var,undef}", "/value"},
      {"{/var,x}/here", "/value/1024/here"},
      {"{/var:1,var}", "/v/value"},
      {"{/list}", "/red,green,blue"},
      {"{/list*}", "/red/green/blue"},
      {"{/list*,path:4}", "/red/green/blue/%2Ffoo"},
      {"{/keys}", "/semi,%3B,dot,.,comma,%2C"},
      {"{/keys*}", "/semi=%3B/dot=./comma=%2C"},
      # Additional cases for 100% coverage
      {"foo{/undef*}", "foo"},
      {"bar{/undef:10}", "bar"},
      {"baz{/empty_keys}", "baz"}
    ]
end
