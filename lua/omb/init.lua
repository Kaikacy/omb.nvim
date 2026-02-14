local M = {}

---@param source_cfg omb.Source.Config
---@param drawer_cfg omb.Drawer.Config
---@param handler_cfg omb.Handler.Config
---@return omb.Selector
-- TODO:
function M.selector(source_cfg, drawer_cfg, handler_cfg)
    local source = require("omb.components.source"):new(source_cfg)
    local drawer = require("omb.components.drawer"):new(drawer_cfg)
    local handler = require("omb.components.handler"):new(handler_cfg)
    return require("omb.selector"):new()
end

return M
