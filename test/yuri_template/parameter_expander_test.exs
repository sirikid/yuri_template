defmodule YuriTemplate.ParameterExpanderTest do
  use ExpanderTest,
    cases: [
      {"{;who}", ";who=fred"},
      {"{;half}", ";half=50%25"},
      {"{;empty}", ";empty"},
      {"{;v,empty,who}", ";v=6;empty;who=fred"},
      {"{;v,bar,who}", ";v=6;who=fred"},
      {"{;x,y}", ";x=1024;y=768"},
      {"{;x,y,empty}", ";x=1024;y=768;empty"},
      {"{;x,y,undef}", ";x=1024;y=768"},
      {"{;hello:5}", ";hello=Hello"},
      {"{;list}", ";list=red,green,blue"},
      {"{;list*}", ";list=red;list=green;list=blue"},
      {"{;keys}", ";keys=semi,%3B,dot,.,comma,%2C"},
      {"{;keys*}", ";semi=%3B;dot=.;comma=%2C"}
    ]
end
