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
        -- key, item, hls (hl: start, end (0-based, end-exclusive), hl group)
        { "1", "abcd", vim.NIL },
        { "2", "abcdef", { { 4, 6, "Comment" } } },
        { "3", "abcdef", { { 0, 4, "Special" }, { 4, 6, "Comment" } } },
        { "4", "abcdef", { { 0, 4, "Special" }, { 4, 6, "Comment" } } },
    }
    local source = M:new({
        provider = function()
            return { 1, 2, 3, 4 }
        end,
        format = function(ctx)
            if ctx.item == 1 then
                return "abcd"
            elseif ctx.item == 2 then
                return { "abcd", { "ef", "Comment" } }
            elseif ctx.item == 3 then
                return { { "abcd", "Special" }, { "ef", "Comment" } }
            elseif ctx.item == 4 then
                return { { "abcd", "Special" }, { "", "Whatever" }, { "ef", "Comment" } }
            else
                error("unreachable")
            end
        end,
        assigner = function(ctx)
            return vim.tbl_map(tostring, ctx.list)
        end,
    })
    source:update()

    for i, key in ipairs(source.ctx.keys) do
        h.eq(expected[i], { key, source.ctx.formatted[i], source.ctx.highlights[i] })
    end
end

return T
