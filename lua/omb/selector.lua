local core = require("omb.core")

---@class omb.Selector
---@field source omb.Source
---@field drawer omb.Drawer
---@field handler omb.Handler
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
    }
    return setmetatable(selector, { __index = self })
end

function Selector:update() end
function Selector:open() end
function Selector:run() end
function Selector:stop() end

return Selector
