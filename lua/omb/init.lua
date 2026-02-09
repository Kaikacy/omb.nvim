local M = {}

---@param config omb.Source.Config
---@return omb.Source
function M.source(config)
    return require("omb.source"):new(config)
end

---@param config omb.Drawer.Config
---@return omb.Drawer
function M.drawer(config)
    return require("omb.drawer"):new(config)
end

---@param config omb.Handler.Config
---@return omb.Handler
function M.handler(config)
    return require("omb.handler"):new(config)
end

---@param source omb.Source
---@param drawer omb.Drawer
---@param handler omb.Handler
---@return omb.Selector
function M.selector(source, drawer, handler) end

return M
