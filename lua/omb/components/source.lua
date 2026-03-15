local utils = require("omb.utils")
local core = require("omb.core")

---@alias omb.Source.Provider fun(ctx: omb.Source.ProviderContext, my: table): list: any[]
---@alias omb.Source.Sorter fun(ctx: omb.Source.SorterContext, my: table): sorted: any[]
---@alias omb.Source.Format fun(ctx: omb.Source.FormatContext, my: table): fmt_items: (omb.Source.FmtItem)[]|string
---@alias omb.Source.Assigner fun(ctx: omb.Source.AssignerContext, my: table): assigned_keys: string[]

---@alias omb.Source.FmtItem [string, string]|string text and hl group or just text
---@alias omb.Source.HlRange [integer, integer, string] start column, end column (0-based, end-exclusive) and hl group
---@alias omb.Source.Highlight omb.Source.HlRange[]

---@class omb.Source.Config
---@field provider omb.Source.Provider
---@field sorter? omb.Source.Sorter
---@field format? omb.Source.Format
---@field assigner omb.Source.Assigner

---@class omb.Source.PartialContext

---@class omb.Source.ProviderContext: omb.Source.PartialContext

---@class omb.Source.SorterContext: omb.Source.ProviderContext
---@field list any[]

---@class omb.Source.AssignerContext: omb.Source.SorterContext
---@field formatted string[]
---@field highlights omb.Source.Highlight[]

---@class omb.Source.FullContext: omb.Source.AssignerContext
---@field keys string[]

---@class omb.Source.FormatContext
---@field item any
---@field index integer

---@class omb.Source
---@field provider omb.Source.Provider
---@field sorter omb.Source.Sorter
---@field format omb.Source.Format
---@field assigner omb.Source.Assigner
---@field id integer
---@field parent_id integer
---@field ctx omb.Source.PartialContext|omb.Source.FullContext
local Source = {}

---@param config omb.Source.Config
---@return omb.Source
function Source:new(config, parent_id)
    ---@type omb.Source
    local source = {
        parent_id = parent_id,
        id = core.next_id(),
        provider = config.provider,
        sorter = config.sorter or function(ctx)
            return ctx.list
        end,
        format = config.format or function(ctx)
            return tostring(ctx.item)
        end,
        assigner = config.assigner,
        ctx = {},
    }
    return setmetatable(source, { __index = self })
end

---@param fmt_items omb.Source.FmtItem[]|string
function Source:_fmt_items_to_pair(fmt_items)
    if type(fmt_items) == "string" then
        return fmt_items, {}
    end
    local text = ""
    local hl_ranges = {}
    local curr_col = 0
    for _, fmt_item in ipairs(fmt_items) do
        if type(fmt_item) == "string" and #fmt_item > 0 then
            -- without hl group this segment won't be highlighted
            -- no need to insert anything in hl_ranges
            text = text .. fmt_item
        elseif type(fmt_item) == "table" and #fmt_item[1] > 0 then
            -- fmt_item: [text, hl group]
            text = text .. fmt_item[1]
            table.insert(hl_ranges, { curr_col, curr_col + #fmt_item[1], fmt_item[2] }) -- start, end, hl group
        end
        curr_col = #text
    end
    return text, hl_ranges
end

---@param parent_id integer
function Source:set_parent(parent_id)
    self.parent_id = parent_id
end

---@return table
function Source:update()
    -- ctx is reference to self.ctx, they point to same data
    -- similarly, user_data table is passed by reference, unless if it's reassigned in user function, then it gets copied
    local ctx = self.ctx
    ---@cast ctx omb.Source.FullContext
    local user_data = {}

    ctx.list = self.provider(ctx, user_data)
    ctx.list = self.sorter(ctx, user_data)
    ctx.formatted = {}
    ctx.highlights = {}
    for i, item in ipairs(ctx.list) do
        local fmt_items = self.format({ item = item, index = i }, user_data)
        local text, hls = self:_fmt_items_to_pair(fmt_items)
        ctx.formatted[i] = text
        ctx.highlights[i] = hls
    end
    ctx.keys = self.assigner(ctx, user_data)

    assert(#ctx.keys > 0, "no keys assigned in source")
    assert(#ctx.list == #ctx.keys, "sorted items and keys length don't match")

    assert(utils.get_first_dup(ctx.keys) == nil, "duplicate key")

    return user_data
end

---@return string[] keys, string[] items,
function Source:get_formatted_list()
    return self.ctx.keys, self.ctx.formatted, self.ctx.highlights
end

return Source
