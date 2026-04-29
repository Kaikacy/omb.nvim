---@class omb.selector.PartialConfig
---@field list omb.selector.list
---@field format? omb.selector.format
---@field validate_list? boolean Ensure list is in valid shape on each run. Disable for maximum performance
---@field width? omb.selector.size
---@field height? omb.selector.size
---@field pos? omb.selector.pos
---@field key_separator? string
---@field extends_char? string

---@class omb.selector.Opts
---@field validate_list boolean
---@field width omb.selector.size
---@field height omb.selector.size
---@field xpos "left"|"center"|"right"
---@field ypos "top"|"center"|"bottom"
---@field key_separator string
---@field extends_char string

---@class omb.selector.State
---@field buf integer
---@field exact_width integer Width needed to fully display all lines
---@field exact_height integer Height needed to fully display all lines

---@alias omb.selector.list fun(data: table): omb.item.Partial[]
---@alias omb.selector.format fun(item: omb.item.Partial, idx: integer, data: table): omb.fmt.item
---@alias omb.selector.size number|[number, number] -- fixed or min, max
---@alias omb.selector.pos "top_left"|"top_center"|"top_right"|"center_left"|"center_center"|"center_right"|"bottom_left"|"bottom_center"|"bottom_right"

---@alias omb.fmt.item omb.fmt.segment[]|string
---@alias omb.fmt.segment [string, string?] Text and optional hl-group

---@class omb.item.Partial
---@field value any
---@field key string
---@field data any Additional user data for each item

---@class omb.item.Full: omb.item.Partial
---@field text string
---@field hl_ranges omb.item.hlRange[]

---@alias omb.item.hlRange [integer, integer, string] start column, end column (0-based, end-exclusive) and hl-group
