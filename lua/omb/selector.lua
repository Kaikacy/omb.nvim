local core = require("omb.core")

---@class omb.Selector
---@field source omb.Source
---@field drawer omb.Drawer
---@field handler omb.Handler
---@field assignments omb.Source.Assignments
---@field assigned_keys omb.Source.AssignedKeys
local Selector = {}

---@param source_cfg omb.Source.Config
---@param drawer_cfg omb.Drawer.Config
---@param handler_cfg omb.Handler.Config
---@return omb.Selector
function Selector:new(source_cfg, drawer_cfg, handler_cfg)
    ---@type omb.Selector
    local selector = {
        source = require("omb.components.source"):new(source_cfg),
        drawer = require("omb.components.drawer"):new(drawer_cfg),
        handler = require("omb.components.handler"):new(handler_cfg),
        assignments = {},
        assigned_keys = {},
    }
    return setmetatable(selector, { __index = self })
end

---@param user_data table
function Selector:update(user_data)
    self.source:update()
    self.assignments, self.assigned_keys = self.source:get()
    self.drawer:update(self.assignments, self.assigned_keys, user_data)
end

---@param user_data table
function Selector:run(user_data)
    self:update(user_data)
    self.drawer:display()
    self.handler:run(self.assignments, self.assigned_keys, user_data)
    self.drawer:hide()
end

return Selector
