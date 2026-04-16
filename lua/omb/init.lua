local core = require("omb.core")

local M = {}

---@param config omb.source.Config
---@return integer id
function M.new_source(config)
    local source = require("omb.components.source").new(config)
    core.register_component(source)
    return source.base.id
end

---@param config omb.display.Config
---@return integer id
function M.new_display(config)
    local display = require("omb.components.display").new(config)
    core.register_component(display)
    return display.base.id
end

---@param config omb.handler.Config
---@return integer id
function M.new_handler(config)
    local handler = require("omb.components.handler").new(config)
    core.register_component(handler)
    return handler.base.id
end

---@param source_id integer
---@param display_id integer
---@param handler_id integer
---@return integer id
function M.new_selector(source_id, display_id, handler_id)
    local selector = require("omb.selector").new(source_id, display_id, handler_id)
    core.register_selector(selector)
    return selector.id
end

---@param selector_id integer
---@param user_data table
function M.run(selector_id, user_data)
    return core.get_selector(selector_id):run(user_data)
end

return M
