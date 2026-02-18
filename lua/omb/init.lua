local M = {}

---@param source_cfg omb.Source.Config
---@param drawer_cfg omb.Drawer.Config
---@param handler_cfg omb.Handler.Config
---@return omb.Selector
-- TODO:
function M.selector(source_cfg, drawer_cfg, handler_cfg)
    return require("omb.selector"):new(source_cfg, drawer_cfg, handler_cfg)
end

return M
