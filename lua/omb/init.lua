local M = {}

---@param config omb.selector.Config
---@return omb.Selector
function M.new_selector(config)
    local selector = require("omb.selector").new(config)
    return selector
end

return M
