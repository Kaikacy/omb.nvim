local core = require("omb.core")
local utils = require("omb.utils")

---@alias omb.Display.Pos "top_left"|"top_center"|"top_right"|"center_left"|"center_center"|"center_right"|"bottom_left"|"bottom_center"|"bottom_right"
---@alias omb.Display.Size number|"flex"|{min?: number, max?: number}

---@class omb.Display.Config
---@field key_separator? string
---@field pos? omb.Display.Pos
---@field width? omb.Display.Size
---@field height? omb.Display.Size
---@field extends_char? string

---@class omb.Display.HighlighterContext
---@field item string
---@field key string

---@class omb.Display.State
---@field buf integer
---@field max_width integer
---@field max_height integer

---@class omb.Display
---@field base omb.BaseComponent
---@field key_separator string
---@field ns number
---@field xpos "left"|"right"|"center"
---@field ypos "top"|"bottom"|"center"
---@field width omb.Display.Size
---@field height omb.Display.Size
---@field extends_char string
---@field state omb.Display.State
local Display = {}

---@param config omb.Display.Config
---@return omb.Display
function Display.new(config)
    local width, height = config.width or "flex", config.height or "flex"
    if type(width) == "number" then
        width = utils.resolve_width(width)
    end
    if type(height) == "number" then
        height = utils.resolve_height(height)
    end
    local ypos, xpos = unpack(vim.fn.split(config.pos or "center_center", "_"))

    ---@type omb.Display
    local display = {
        base = require("omb.components.base").new(),
        key_separator = config.key_separator or " | ",
        xpos = xpos,
        ypos = ypos,
        width = width,
        height = height,
        extends_char = config.extends_char or ">",
        ns = core.state.ns,
        state = {
            buf = -1,
            max_width = -1,
            max_height = -1,
        },
    }
    return setmetatable(display, { __index = Display })
end

---fails if update wasn't called as max_width/height are invalid
---@return integer row, integer col, integer width, integer height, string anchor
function Display:_get_rect()
    local width, height = self.width, self.height
    if width == "flex" then
        width = self.state.max_width
    elseif type(width) == "table" then
        width = utils.resolve_width(utils.clamp(self.state.max_width, width.min or 0, width.max or 1))
    end
    if height == "flex" then
        height = self.state.max_height
    elseif type(height) == "table" then
        height = utils.resolve_height(utils.clamp(self.state.max_height, height.min or 0, height.max or 1))
    end
    ---@cast width integer
    ---@cast height integer

    local row, col, yanchor, xanchor
    if self.ypos == "top" then
        yanchor = "N" -- north
        row = 0
    elseif self.ypos == "bottom" then
        yanchor = "S" -- south
        row = vim.o.lines
    elseif self.ypos == "center" then
        yanchor = "N"
        row = vim.fn.round((vim.o.lines - height) * 0.5)
    end
    if self.xpos == "left" then
        xanchor = "W" -- west
        col = 0
    elseif self.xpos == "right" then
        xanchor = "E" -- east
        col = vim.o.columns
    elseif self.xpos == "center" then
        xanchor = "W"
        col = vim.fn.round((vim.o.columns - width) * 0.5)
    end
    return row, col, width, height, yanchor .. xanchor
end

function Display:update()
    if not vim.api.nvim_buf_is_valid(self.state.buf) then
        self.state.buf = vim.api.nvim_create_buf(false, true)
        assert(self.state.buf ~= 0, "couldn't create buffer")
    end
    local buf = self.state.buf

    local keys, items, highlights = self.base:get_parent():get_child_source():get_formatted_list()

    local lines = {}
    for _, key, item in utils.zip_iter(keys, items) do
        local line = key .. self.key_separator .. item
        table.insert(lines, line)
        if self.state.max_width < #line then
            self.state.max_width = #line
        end
    end
    self.state.max_height = #lines

    -- clear the buffer (TODO: this shouldn't be done always, like when reusing cached values, once I add cache)
    vim.api.nvim_buf_clear_namespace(buf, self.ns, 0, -1)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    -- display lines
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)

    for i, key, hl_ranges in utils.zip_iter(keys, highlights) do
        local item_start = #key + #self.key_separator
        for _, hl_range in ipairs(hl_ranges) do
            vim.api.nvim_buf_set_extmark(
                buf,
                self.ns,
                i - 1, -- 0-based
                hl_range[1] + item_start,
                { end_col = hl_range[2] + item_start, hl_group = hl_range[3] }
            )
        end
    end
end

function Display:show()
    assert(not vim.api.nvim_win_is_valid(core.state.win), "another display is active")
    assert(vim.api.nvim_buf_is_valid(self.state.buf), "buffer isn't valid")

    local row, col, width, height, anchor = self:_get_rect()

    local win = vim.api.nvim_open_win(self.state.buf, false, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        anchor = anchor,
        style = "minimal",
        focusable = false,
        zindex = 90,
    })
    vim.wo[win].wrap = false
    vim.wo[win].list = true
    vim.wo[win].listchars = "extends:" .. self.extends_char
    core.state.win = win
end

function Display:hide()
    assert(vim.api.nvim_win_is_valid(core.state.win), "window should be open before calling close")
    vim.api.nvim_win_hide(core.state.win)
end

return Display
