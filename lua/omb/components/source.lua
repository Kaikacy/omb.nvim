local utils = require("omb.utils")

---@alias omb.Source.Provider fun(ctx: omb.Source.ProviderContext, my: table): list: any[]
---@alias omb.Source.Sorter fun(ctx: omb.Source.SorterContext, my: table): sorted: any[]
---@alias omb.Source.Formatter fun(ctx: omb.Source.FormatterContext, my: table): formatted: string[]
---@alias omb.Source.Assigner fun(ctx: omb.Source.AssignerContext, my: table): assigned_keys: string[]

---@class omb.Source.Config
---@field provider omb.Source.Provider
---@field sorter? omb.Source.Sorter
---@field formatter? omb.Source.Formatter
---@field assigner omb.Source.Assigner

---@class omb.Source.PartialContext

---@class omb.Source.ProviderContext: omb.Source.PartialContext

---@class omb.Source.SorterContext: omb.Source.ProviderContext
---@field list any[]

---@class omb.Source.FormatterContext: omb.Source.SorterContext

---@class omb.Source.AssignerContext: omb.Source.FormatterContext
---@field formatted string[]

---@class omb.Source.FullContext: omb.Source.AssignerContext
---@field keys string[]

---@class omb.Source
---@field provider omb.Source.Provider
---@field sorter omb.Source.Sorter
---@field formatter omb.Source.Formatter
---@field assigner omb.Source.Assigner
---@field package ctx omb.Source.PartialContext|omb.Source.FullContext
local Source = {}

---@param config omb.Source.Config
---@return omb.Source
function Source:new(config)
    ---@type omb.Source
    local source = {
        provider = config.provider,
        sorter = config.sorter or function(ctx)
            return ctx.list
        end,
        formatter = config.formatter or function(ctx)
            return vim.tbl_map(tostring, ctx.list)
        end,
        assigner = config.assigner,
        ctx = {},
    }
    return setmetatable(source, { __index = self })
end

---@return table
function Source:update()
    local ctx = self.ctx
    ---@cast ctx omb.Source.FullContext
    local user_data = {}

    ctx.list = self.provider(ctx, user_data)
    ctx.list = self.sorter(ctx, user_data)
    ctx.formatted = self.formatter(ctx, user_data)
    ctx.keys = self.assigner(ctx, user_data)

    assert(#ctx.keys > 0, "no keys assigned in source")
    assert(#ctx.list == #ctx.keys, "sorted items and keys length don't match")

    assert(utils.get_first_dup(ctx.keys) == nil, "duplicate key")

    self.ctx = ctx
    return user_data
end

---@return string[] keys, string[] items
function Source:get_formatted_list()
    return self.ctx.keys, self.ctx.formatted
end

return Source
