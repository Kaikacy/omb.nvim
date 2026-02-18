local M = {}

-- Global state
local state = {
    win = -1,
    ns = vim.api.nvim_create_namespace("omb-drawer"),
}

M.state = {}
setmetatable(M.state, { __index = state })

return M
