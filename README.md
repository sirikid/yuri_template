
# Table of Contents

1.  [What](#org179e2dd)
2.  [Alternatives](#org80e3187)
    1.  [`uri_template`](#org59d69ac)
    2.  [URI](#org643fdeb)
3.  [Examples](#orgf4295fe)
4.  [Copyright notice](#org19f00b4)

[![builds.sr.ht status](https://builds.sr.ht/~sokolov/yuri_template.svg)](https://builds.sr.ht/~sokolov/yuri_template?)


<a id="org179e2dd"></a>

# What

 [RFC6570](https://tools.ietf.org/html/rfc6570) describes the template language for URIs. It can be used to
generate hierarchical URIs, queries, fragments, and more.


<a id="org80e3187"></a>

# Alternatives


<a id="org59d69ac"></a>

## [`uri_template`](https://hex.pm/packages/uri_template)

Another implementation of the same RFC. Uses regular expressions to
parse templates and can silently ignore errors in them.


<a id="org643fdeb"></a>

## [URI](https://hexdocs.pm/elixir/URI.html)

Built-in module for managing URIs. It does not support templates,
but can handle simple tasks, such as encoding a query.


<a id="orgf4295fe"></a>

# Examples

    YuriTemplate.expand!("https://tools.ietf.org{/path*}", path: ["html", "rfc6570"])

    "https://tools.ietf.org/html/rfc6570"


<a id="org19f00b4"></a>

# Copyright notice

    Copyright 2020 Ivan Sokolov

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
