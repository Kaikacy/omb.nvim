local utils = require("omb.utils")

---@alias omb.Handler.Action fun(ctx: omb.Handler.ActionContext): any

---@class omb.Handler.ActionContext
---@field key string
---@field item any
---@field formatted string
---@field index integer

---@class omb.Handler.Config
---@field cancel_key? string|string[]
---@field action? omb.Handler.Action

---@class omb.Handler
---@field base omb.BaseComponent
---@field action omb.Handler.Action
---@field cancel_keys string[]
local Handler = {}

---@param config omb.Handler.Config
function Handler.new(config)
    local cancel_keys = { "" } -- <ESC>
    if type(config.cancel_key) == "string" then
        cancel_keys = { vim.keycode(config.cancel_key) }
    elseif type(config.cancel_key) == "table" then
        cancel_keys = vim.tbl_map(function(key)
            return vim.keycode(key)
        end, config.cancel_key)
    end
    ---@type omb.Handler
    local handler = {
        base = require("omb.components.base").new(),
        action = config.action or function(ctx)
            return ctx
        end,
        cancel_keys = cancel_keys,
    }
    return setmetatable(handler, { __index = Handler })
end

---@param source_ctx omb.Source.FullContext
---@return omb.Handler.ActionContext?
function Handler:run(source_ctx)
    -- TODO: catch interupt (<C-c>)
    local char = vim.fn.getcharstr(-1, { cursor = "keep" })

    for _, cancel_key in ipairs(self.cancel_keys) do
        if char == cancel_key then
            return
        end
    end

    for i, key, item, formatted in utils.zip_iter3(source_ctx.keys, source_ctx.list, source_ctx.formatted) do
        if char == vim.keycode(key) then
            return self.action({ key = key, item = item, formatted = formatted, index = i })
        end
    end
    -- error("input char isn't assigned to item")
end

return Handler
