local utils = require("omb.utils")

---@alias omb.Source.Provider fun(my: table): omb.Source.PartialItem[]
---@alias omb.Source.Format fun(item: omb.Source.PartialItem, idx: integer, my: table): omb.Source.FmtItem

---@alias omb.Source.FmtSegment [string, string?] text and hl-group or just text
---@alias omb.Source.FmtItem omb.Source.FmtSegment[]|string
---@alias omb.Source.HlRange [integer, integer, string] start column, end column (0-based, end-exclusive) and hl-group

---@class omb.Source.Config
---@field provider omb.Source.Provider
---@field format? omb.Source.Format

---@class omb.Source.PartialItem
---@field value any
---@field key string
---@field data any item user data

---@class omb.Source.Item: omb.Source.PartialItem
---@field text string
---@field hl_ranges omb.Source.HlRange[]

---@class omb.Source
---@field base omb.BaseComponent
---@field provider omb.Source.Provider
---@field format omb.Source.Format
---@field items omb.Source.PartialItem[]|omb.Source.Item[]
local Source = {}

---@param config omb.Source.Config
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

---@param fmt_item omb.Source.FmtItem
---@return string, omb.Source.HlRange[]
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
        ---@cast item omb.Source.Item
        item.text = text
        item.hl_ranges = hl_ranges
    end
    ---@cast items omb.Source.Item[]

    -- TODO: shouldn't be assert
    assert(utils.get_first_dup(utils.get_field_list(items, "keys")) == nil, "duplicate key")
end

return Source
