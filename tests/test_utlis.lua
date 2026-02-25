local h = require("tests.helper")
local expect, eq = MiniTest.expect, MiniTest.expect.equality

local T, child = h.test_set_with_child("omb.utils")

T["resolve width"] = function()
    child.o.columns = 50
    eq(child.lua_get([[M.resolve_width(0.1)]]), 5)
    eq(child.lua_get([[M.resolve_width(1)]]), 50)
    eq(child.lua_get([[M.resolve_width(20)]]), 20)
end
T["resolve height"] = function()
    child.o.lines = 20
    eq(child.lua_get([[M.resolve_height(0.1)]]), 2)
    eq(child.lua_get([[M.resolve_height(1)]]), 20)
    eq(child.lua_get([[M.resolve_height(10)]]), 10)
end
T["clamp"] = function()
    eq(child.lua_get([[M.clamp(5, 3, 10)]]), 5)
    eq(child.lua_get([[M.clamp(1, 3, 10)]]), 3)
    eq(child.lua_get([[M.clamp(12, 3, 10)]]), 10)
    eq(child.lua_get([[M.clamp(8, 5, 5)]]), 5)
    expect.error(function()
        child.lua([[M.clamp(5, 10, 3)]])
    end)
end

return T
