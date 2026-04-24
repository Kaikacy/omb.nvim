local core = require("omb.core")

---@class omb.Selector
---@field source_id integer
---@field display_id integer
---@field handler_id integer
---@field id integer
local Selector = {}
Selector.__index = Selector

---@return omb.Selector
function Selector.new(source_id, display_id, handler_id)
    local id = core.next_id()
    ---@type omb.Selector
    local selector = {
        id = id,
        source_id = source_id,
        display_id = display_id,
        handler_id = handler_id,
    }
    return setmetatable(selector, Selector)
end

function Selector:get_child_source()
    ---@type omb.Source
    return core.get_component(self.source_id)
end

function Selector:get_child_display()
    ---@type omb.Display
    return core.get_component(self.display_id)
end

function Selector:get_child_handler()
    ---@type omb.Handler
    return core.get_component(self.handler_id)
end

function Selector:run(user_data)
    core.activate_selector(self.id)
    local source = self:get_child_source()
    local display = self:get_child_display()
    local handler = self:get_child_handler()
    -- TODO: only update when needed; add cache
    source:update(user_data)
    display:update(source.items)
    display:show()
    local out
    vim.schedule(function()
        out = handler:run(source.items)
        display:hide()
    end)
    return out
end

return Selector
