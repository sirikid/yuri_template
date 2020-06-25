
# Table of Contents

1.  [What](#org524421c)
2.  [Alternatives](#org8cc01bd)
    1.  [`uri_template`](#org6b190c9)
    2.  [URI](#orga801b78)
3.  [Examples](#org4afad11)
4.  [Copyright notice](#org3ef8778)



<a id="org524421c"></a>

# What

 [RFC6570](https://tools.ietf.org/html/rfc6570) describes the template language for URIs. It can be used to
generate hierarchical URIs, queries, fragments, and more.


<a id="org8cc01bd"></a>

# Alternatives


<a id="org6b190c9"></a>

## [`uri_template`](https://hex.pm/packages/uri_template)

Another implementation of the same RFC. Uses regular expressions to
parse templates and can silently ignore errors in them.


<a id="orga801b78"></a>

## [URI](https://hexdocs.pm/elixir/URI.html)

Built-in module for managing URIs. It does not support templates,
but can handle simple tasks, such as encoding a query.


<a id="org4afad11"></a>

# Examples

    YuriTemplate.expand!("https://tools.ietf.org{/path*}", path: ["html", "rfc6570"])

    "https://tools.ietf.org/html/rfc6570"


<a id="org3ef8778"></a>

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
