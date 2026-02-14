---@alias omb.Source.Provider fun(ctx: omb.Source.ProviderContext, my: table): list: any[]
---@alias omb.Source.Formatter fun(ctx: omb.Source.FormatterContext, my: table): formatted: string[]
---@alias omb.Source.Assigner fun(ctx: omb.Source.AssignerContext, my: table): assignments: omb.Source.Assignments, assigned_keys: string[]

---@alias omb.Source.Assignments table<string, string>
---@alias omb.Source.AssignedKeys string[]

---@class omb.Source.Config
---@field provider omb.Source.Provider
---@field formatter? omb.Source.Formatter
---@field assigner omb.Source.Assigner

---@class omb.Source.PartialContext

---@class omb.Source.ProviderContext: omb.Source.PartialContext

---@class omb.Source.FormatterContext: omb.Source.ProviderContext
---@field list any[]

---@class omb.Source.AssignerContext: omb.Source.FormatterContext
---@field formatted string[]

---@class omb.Source.FullContext: omb.Source.AssignerContext
---@field assignments omb.Source.Assignments
---@field assigned_keys string[]

---@class omb.Source
---@field provider omb.Source.Provider
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
    ctx.formatted = self.formatter(ctx, user_data)
    ctx.assignments, ctx.assigned_keys = self.assigner(ctx, user_data)

    assert(#ctx.assigned_keys > 0, "no items in source")

    self.ctx = ctx
    return user_data
end

---@return omb.Source.Assignments, omb.Source.AssignedKeys
function Source:get()
    -- update has to be called at least once
    assert(self.ctx.assignments, "ctx has to have type FullContext before calling get")
    return self.ctx.assignments, self.ctx.assigned_keys
end

return Source
