local utils = require("omb.utils")

---@alias omb.source.provider fun(my: table): omb.source.PartialItem[]
---@alias omb.source.format fun(item: omb.source.PartialItem, idx: integer, my: table): omb.source.fmtItem

---@alias omb.source.fmtSegment [string, string?] text and hl-group or just text
---@alias omb.source.fmtItem omb.source.fmtSegment[]|string
---@alias omb.source.hlRange [integer, integer, string] start column, end column (0-based, end-exclusive) and hl-group

---@class omb.source.Config
---@field provider omb.source.provider
---@field format? omb.source.format

---@class omb.source.PartialItem
---@field value any
---@field key string
---@field data any item user data

---@class omb.source.Item: omb.source.PartialItem
---@field text string
---@field hl_ranges omb.source.hlRange[]

---@class omb.Source
---@field base omb.BaseComponent
---@field provider omb.source.provider
---@field format omb.source.format
---@field items omb.source.PartialItem[]|omb.source.Item[]
local Source = {}

---@param config omb.source.Config
---@return omb.Source
function Source.new(config)
    ---@type omb.Source
    local source = {
        base = require("omb.components.base").new(),
        provider = config.provider,
        format = config.format or function(item)
            return { tostring(item.value) }
        end,
        items = {},
    }
    return setmetatable(source, { __index = Source })
end

---@param fmt_item omb.source.fmtItem
---@return string, omb.source.hlRange[]
function Source:_fmt_item_to_pair(fmt_item)
    if type(fmt_item) == "string" then
        return fmt_item, {}
    end
    local text = ""
    local hl_ranges = {}
    local curr_col = 0
    for _, segment in ipairs(fmt_item) do
        if #segment[1] > 0 then
            text = text .. segment[1]
            if #segment == 2 then
                -- segment: [text, hl-group]
                table.insert(hl_ranges, { curr_col, curr_col + #segment[1], segment[2] }) -- start, end, hl-group
            end
            curr_col = #text
        end
    end
    return text, hl_ranges
end

---@param user_data table
function Source:update(user_data)
    -- user_data table is passed by reference, unless if it's reassigned in user function, then it gets copied

    local items = self.provider(user_data)

    for i, item in ipairs(items) do
        local fmt_item = self.format(item, i, user_data)
        local text, hl_ranges = self:_fmt_item_to_pair(fmt_item)
        ---@cast item omb.source.Item
        item.text = text
        item.hl_ranges = hl_ranges
    end
    ---@cast items omb.source.Item[]

    -- TODO: shouldn't be assert
    assert(utils.get_first_dup(utils.get_field_list(items, "keys")) == nil, "duplicate key")

    self.items = items
end

return Source
