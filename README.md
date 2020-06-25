
# Table of Contents

1.  [Examples](#org777483e)
2.  [Copyright notice](#orge479ba0)



<a id="org777483e"></a>

# Examples

If you're viewing this file on Github you should know that it ignores
results. Even when `:exports both` specified.

    YuriTemplate.expand!("https://ja.wikipedia.org/wiki/{title}", title: "少女セクト")

    "https://ja.wikipedia.org/wiki/%E5%B0%91%E5%A5%B3%E3%82%BB%E3%82%AF%E3%83%88"

    YuriTemplate.expand!("https://anilist.co{/path*}", path: ~w(anime 10495 Yuru-Yuri))

    "https://anilist.co/anime/10495/Yuru-Yuri"

    YuriTemplate.expand!(
      "https://gelbooru.com/index.php{?query*}",
      query: [{"page", "post"}, {"s", "list"}, {"tags", "tenjou_utena"}]
    )

    "https://gelbooru.com/index.php?page=post&s=list&tags=tenjou_utena"


<a id="orge479ba0"></a>

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
