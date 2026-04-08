local core = require("omb.core")

---@class omb.BaseComponent
---@field id integer
---@field parent_id integer
local Base = {}

---@return omb.BaseComponent
function Base.new()
    local base = {
        id = core.next_id(),
        parent_id = -1,
    }
    return setmetatable(base, { __index = Base })
end

function Base:parent()
    return core.get_selector(self.parent_id)
end

return Base
