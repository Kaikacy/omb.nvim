local h = require("tests.helper")
local M = require("omb.components.source")
local T = MiniTest.new_set()

T["get formatted list"] = function()
    local expected = {
        { "a", "1" },
        { "b", "2" },
        { "c", "3" },
        { "d", "4" },
    }
    local source = M:new({
        provider = function()
            return { 1, 2, 3, 4 }
        end,
        assigner = function(ctx)
            return { "a", "b", "c", "d" }
        end,
    })
    source:update()

    local keys, items = source:get_formatted_list()
    for i, key, item in require("omb.utils").zip_iter(keys, items) do
        h.eq(expected[i], { key, item })
    end
end

return T
