local h = require("tests.helper")
local M = require("omb.components.source")
local T = MiniTest.new_set()

T["get_formatted_list"] = function()
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
        assigner = function()
            return { "a", "b", "c", "d" }
        end,
    })
    source:update()

    local keys, items = source:get_formatted_list()
    for i, key, item in require("omb.utils").zip_iter(keys, items) do
        h.eq(expected[i], { key, item })
    end
end
T["format function"] = function()
    local expected = {
        { "a", "a1" },
        { "b", "b2" },
        { "c", "c3" },
        { "d", "d4" },
    }
    local source = M:new({
        provider = function()
            return { 1, 2, 3, 4 }
        end,
        format = function(ctx)
            return string.char(96 + ctx.item) .. tostring(ctx.item)
        end,
        assigner = function(ctx)
            return vim.tbl_map(function(x)
                return string.sub(x, 1, 1)
            end, ctx.formatted)
        end,
    })
    source:update()

    local keys, items = source:get_formatted_list()
    for i, key, item in require("omb.utils").zip_iter(keys, items) do
        h.eq(expected[i], { key, item })
    end
end

return T
