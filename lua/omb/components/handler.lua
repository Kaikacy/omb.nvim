local utils = require("omb.utils")

---@alias omb.handler.action fun(item: omb.source.Item, idx: integer): any

---@class omb.handler.Config
---@field cancel_key? string|string[]
---@field action? omb.handler.action

---@class omb.Handler
---@field base omb.BaseComponent
---@field action omb.handler.action
---@field cancel_keys string[]
local Handler = {}
Handler.__index = Handler

---@param config omb.handler.Config
function Handler.new(config)
    local cancel_keys = config.cancel_key
    if type(cancel_keys) == "nil" then
        cancel_keys = { "" } -- <ESC>
    elseif type(cancel_keys) == "string" then
        cancel_keys = { vim.keycode(cancel_keys) }
    elseif type(config.cancel_key) == "table" then
        cancel_keys = vim.tbl_map(function(key)
            return vim.keycode(key)
        end, cancel_keys)
    else
        error("Handler: invalid cancel_key")
    end
    ---@type omb.Handler
    local handler = {
        base = require("omb.components.base").new(),
        action = config.action or function(ctx)
            return ctx
        end,
        cancel_keys = cancel_keys,
    }
    return setmetatable(handler, Handler)
end

---@param items omb.source.Item[]
---@return any
function Handler:run(items)
    -- TODO: catch interupt (<C-c>)
    local char = vim.fn.getcharstr(-1, { cursor = "keep" })

    for _, cancel_key in ipairs(self.cancel_keys) do
        if char == cancel_key then
            return
        end
    end

    for i, item in ipairs(items) do
        -- TODO: should't run keycode every time
        if char == vim.keycode(item.key) then
            return self.action(item, i)
        end
    end
    -- error("input char isn't assigned to item")
end

return Handler
