---@alias omb.Component omb.Source|omb.Drawer|omb.Handler

local M = {}

---@class omb.State
---@field win integer
---@field ns integer
---@field selectors omb.Selector[]
---@field components omb.Component[]
---@field safe_id integer

---Global state
---@type omb.State
local state = {
    win = -1,
    ns = vim.api.nvim_create_namespace("omb-drawer"),
    selectors = {},
    components = {},
    safe_id = 0, -- unique id; shall be used for everything
}
---@type omb.State|{}
M.state = {}
setmetatable(M.state, { __index = state })

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

---@param component omb.Component
function M.register_component(component)
    state.components[component.id] = component
end

---@param id integer
---@return omb.Component
function M.get_component(id)
    return state.components[id]
end

---@param component_id integer
---@param parent_id integer
function M.set_component_parent(component_id, parent_id)
    state.components[component_id].parent_id = parent_id
end

return M
