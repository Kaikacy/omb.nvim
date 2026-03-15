local M = {}

-- Global state
local state = {
    win = -1,
    ns = vim.api.nvim_create_namespace("omb-drawer"),
    selectors = {},
    safe_id = 0, -- unique id; shall be used for everything
}
M.state = {}
setmetatable(M.state, { __index = state })

function M.next_id()
    state.safe_id = state.safe_id + 1
    return state.safe_id
end

function M.register_selector(selector)
    state.selectors[selector.id] = selector
end

function M.get_selector(id)
    return state.selectors[id]
end

return M
