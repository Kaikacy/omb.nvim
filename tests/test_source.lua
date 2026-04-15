local h = require("tests.helper")
local M = require("omb.components.source")
local T = MiniTest.new_set()

T["update"] = function()
    local expected = {
        -- key, value, text, hl_ranges (hl_range: start, end (0-based, end-exclusive), hl-group)
        { "a", 1, "1", {} },
        { "b", 2, "2 text", { { 0, 1, "Comment" } } },
        { "c", 3, "3 text", { { 0, 1, "Special" } } },
        { "d", 4, "4", {} },
    }
    local source = M.new({
        provider = function()
            return {
                { key = "a", value = 1 },
                { key = "b", value = 2 },
                { key = "c", value = 3 },
                { key = "d", value = 4 },
            }
        end,
        format = function(item)
            if item.value == 2 then
                return { { "2 text", "Comment" } }
            elseif item.value == 3 then
                return { { "3 text", "Special" } }
            end
            return tostring(item.value)
        end,
    })
    source:update({})

    for i, item in ipairs(source.items) do
        h.eq(expected[i], { item.key, item.value, item.text, item.hl_ranges })
    end
end
T["format"] = function()
    local expected = {
        -- text, hl_ranges (hl_range: start, end (0-based, end-exclusive), hl-group)
        { "abcd", {} },
        { "abcdef", {} },
        { "abcdef", { { 4, 6, "Comment" } } },
        { "abcdef", { { 0, 4, "Special" }, { 4, 6, "Comment" } } },
        { "abcdef", { { 0, 4, "Special" }, { 4, 6, "Comment" } } },
    }
    local source = M.new({
        provider = function()
            local items = {}
            for i = 1, 5 do
                items[i] = { key = tostring(i), value = i }
            end
            return items
        end,
        format = function(item, i)
            h.eq(item.value, i)
            if item.value == 1 then
                return "abcd"
            elseif item.value == 2 then
                return { { "abcd" }, { "ef" } }
            elseif item.value == 3 then
                return { { "abcd" }, { "ef", "Comment" } }
            elseif item.value == 4 then
                return { { "abcd", "Special" }, { "ef", "Comment" } }
            elseif item.value == 5 then
                return { { "abcd", "Special" }, { "", "Whatever" }, { "ef", "Comment" } }
            else
                error("unreachable")
            end
        end,
    })
    source:update({})

    for i, item in ipairs(source.items) do
        h.eq(expected[i], { item.text, item.hl_ranges })
    end
end

return T
