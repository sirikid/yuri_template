[![builds.sr.ht status](https://builds.sr.ht/~sokolov/yuri_template.svg)](https://builds.sr.ht/~sokolov/yuri_template?)


# What

`yuri_template` is an implementation of [RFC6570](https://tools.ietf.org/html/rfc6570), that describes the
template language for URIs. It can be used to generate hierarchical
URIs, queries, fragments, and more.


# Alternatives


## [`uri_template`](https://hex.pm/packages/uri_template)

Another implementation of the same RFC. Uses regular expressions to
parse templates and can silently ignore errors in them.


## [URI](https://hexdocs.pm/elixir/URI.html)

Built-in module for managing URIs. It does not support templates,
but can handle simple tasks, such as encoding a query.


# Examples

    YuriTemplate.expand!("https://tools.ietf.org{/path*}", path: ["html", "rfc6570"])

    "https://tools.ietf.org/html/rfc6570"


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
