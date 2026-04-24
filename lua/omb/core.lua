---@alias omb.Component omb.Source|omb.Display|omb.Handler

local M = {}

---@class omb.State
---@field ns integer
---@field win integer
---@field selector integer
---@field selectors omb.Selector[]
---@field components omb.Component[]
---@field safe_id integer
---Global state
local state = {
    ns = vim.api.nvim_create_namespace("omb-display"),
    win = -1,
    selector = -1,
    selectors = {},
    components = {},
    safe_id = 1000, -- unique id; 1-999 is reserved
}
state.__index = state
---@type omb.State|{}
M.state = {}
setmetatable(M.state, state)

function M.next_id()
    state.safe_id = state.safe_id + 1
    return state.safe_id
end

---@param selector omb.Selector
function M.register_selector(selector)
    state.selectors[selector.id] = selector
end

---@param id integer
---@return omb.Selector
function M.get_selector(id)
    return state.selectors[id]
end

function M.get_active_selector()
    return state.selectors[state.selector]
end

---@param id integer
function M.activate_selector(id)
    assert(state.selector == -1, "another selector is active")
    state.selector = id
end

---@param component omb.Component
function M.register_component(component)
    state.components[component.base.id] = component
end

---@param id integer
---@return omb.Component
function M.get_component(id)
    return state.components[id]
end

return M
