# defmodule YuriTemplate.TagExpander do
#   use YuriTemplate.Expander

#   @impl true
#   def expand_value(acc, var, val) do
#     [val, ?=, to_string(var), ?; | acc]
#   end
# end
