local h = require("tests.helper")
local M = require("omb.utils")
local T, child = h.test_set_with_child("omb.utils")

T["resolve width"] = function()
    child.o.columns = 50
    h.eq(child.lua_get([[M.resolve_width(0.1)]]), 5)
    h.eq(child.lua_get([[M.resolve_width(1)]]), 50)
    h.eq(child.lua_get([[M.resolve_width(20)]]), 20)
end
T["resolve height"] = function()
    child.o.lines = 20
    h.eq(child.lua_get([[M.resolve_height(0.1)]]), 2)
    h.eq(child.lua_get([[M.resolve_height(1)]]), 20)
    h.eq(child.lua_get([[M.resolve_height(10)]]), 10)
end
T["clamp"] = function()
    h.eq(child.lua_get([[M.clamp(5, 3, 10)]]), 5)
    h.eq(child.lua_get([[M.clamp(1, 3, 10)]]), 3)
    h.eq(child.lua_get([[M.clamp(12, 3, 10)]]), 10)
    h.eq(child.lua_get([[M.clamp(8, 5, 5)]]), 5)
    h.expect.error(function()
        child.lua([[M.clamp(5, 10, 3)]])
    end)
end
T["get first dup"] = function()
    h.eq(child.lua_get([[M.get_first_dup({1, 2, 3, 2, 4})]]), 2)
    h.eq(child.lua_get([[M.get_first_dup({1, 2, 3, 4})]]), vim.NIL)
end
T["zip iter"] = function()
    local expected = {
        { "a", "A" },
        { "b", "B" },
        { "c", "C" },
        { "d", "D" },
    }
    local list1 = { "a", "b", "c", "d" }
    local list2 = { "A", "B", "C", "D" }
    for i, elem1, elem2 in M.zip_iter(list1, list2) do
        h.eq({ elem1, elem2 }, expected[i])
    end
end

return T
