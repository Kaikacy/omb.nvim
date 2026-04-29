local M = {}

---@class omb.State
---@field ns integer
---@field win integer
---@field is_active boolean
---Global state
local state = {
    ns = vim.api.nvim_create_namespace("omb-highlight"),
    win = -1,
    is_active = false,
}
state.__index = state
---@type omb.State|{}
M.state = {}
setmetatable(M.state, state)

return M
