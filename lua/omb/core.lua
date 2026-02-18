local M = {}

-- Global state
local state = {
    win = -1,
}

M.state = {}
setmetatable(M.state, { __index = state })

return M
