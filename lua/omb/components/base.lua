local core = require("omb.core")

---@class omb.BaseComponent
---@field id integer
local Base = {}

---@return omb.BaseComponent
function Base.new()
    local base = {
        id = core.next_id(),
    }
    return setmetatable(base, { __index = Base })
end

return Base
