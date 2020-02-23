defmodule YuriTemplate.QueryExpanderTest do
  use ExpanderTest,
    cases: [
      {"{?who}", "?who=fred"},
      {"{?half}", "?half=50%25"},
      {"{?x,y}", "?x=1024&y=768"},
      {"{?x,y,empty}", "?x=1024&y=768&empty="},
      {"{?x,y,undef}", "?x=1024&y=768"},
      {"{?var:3}", "?var=val"},
      {"{?list}", "?list=red,green,blue"},
      {"{?list*}", "?list=red&list=green&list=blue"},
      {"{?keys}", "?keys=semi,%3B,dot,.,comma,%2C"},
      {"{?keys*}", "?semi=%3B&dot=.&comma=%2C"}
    ]
end
