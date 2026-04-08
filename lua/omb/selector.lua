local core = require("omb.core")

---@class omb.Selector
---@field source_id integer
---@field display_id integer
---@field handler_id integer
---@field id integer
local Selector = {}

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
    core.set_component_parent(source_id, id)
    core.set_component_parent(display_id, id)
    core.set_component_parent(handler_id, id)

    return setmetatable(selector, { __index = Selector })
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

return Selector
