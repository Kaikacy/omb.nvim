local utils = require("omb.utils")
---
---@alias omb.Handler.Action fun(ctx: omb.Handler.ActionContext, my: table)

---@class omb.Handler.ActionContext
---@field key string
---@field formatted string
----@field item any
---@field index integer

---@class omb.Handler.Config
---@field cancel_key? string|string[]
---@field action omb.Handler.Action

---@class omb.Handler
---@field action omb.Handler.Action
---@field cancel_keys string[]
local Handler = {}

---@param config omb.Handler.Config
function Handler:new(config)
    local cancel_keys = config.cancel_key or { "<esc>" }
    if type(cancel_keys) == "string" then
        cancel_keys = { cancel_keys }
    end
    ---@type omb.Handler
    local handler = {
        action = config.action,
        cancel_keys = cancel_keys,
    }
    return setmetatable(handler, { __index = self })
end

---@param keys string[]
---@param items string[]
---@param user_data table
function Handler:run(keys, items, user_data)
    -- TODO: catch interupt (<C-c>)
    -- TODO: case-sensitivity (configurable)
    -- TODO: instead of calling action directly, defer it at the end of selector (maybe configurable)
    local char = vim.fn.getcharstr(-1, { cursor = "keep" })
    for _, key in ipairs(self.cancel_keys) do
        if char == vim.api.nvim_replace_termcodes(key, true, true, true) then
            return
        end
    end
    for i, key, item in utils.zip_iter(keys, items) do
        if char == key:lower() then
            self.action({ key = key, formatted = item, index = i }, user_data)
            return
        end
    end
    -- error("input char isn't assigned to item")
end

return Handler
