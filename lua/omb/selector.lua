local core = require("omb.core")

---@class omb.Selector
---@field source omb.Source
---@field drawer omb.Drawer
---@field handler omb.Handler
---@field id integer
local Selector = {}

local M = {}

---@param source_cfg omb.Source.Config
---@param drawer_cfg omb.Drawer.Config
---@param handler_cfg omb.Handler.Config
---@return integer selector_id
function M.new(source_cfg, drawer_cfg, handler_cfg)
    local id = core.next_id()
    local selector = {
        id = id,
    }
    core.register_selector(selector)
    return id
end

return M
