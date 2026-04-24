local core = require("omb.core")
local utils = require("omb.utils")

---@alias omb.display.pos "top_left"|"top_center"|"top_right"|"center_left"|"center_center"|"center_right"|"bottom_left"|"bottom_center"|"bottom_right"
---@alias omb.display.size number|"flex"|{min?: number, max?: number}

---@class omb.display.Config
---@field key_separator? string
---@field pos? omb.display.pos
---@field width? omb.display.size
---@field height? omb.display.size
---@field extends_char? string

---@class omb.display.State
---@field buf integer
---@field max_width integer
---@field max_height integer

---@class omb.Display
---@field base omb.BaseComponent
---@field key_separator string
---@field xpos "left"|"right"|"center"
---@field ypos "top"|"bottom"|"center"
---@field width omb.display.size
---@field height omb.display.size
---@field extends_char string
---@field state omb.display.State
local Display = {}
Display.__index = Display

---@param config omb.display.Config
---@return omb.Display
function Display.new(config)
    local width, height = config.width or "flex", config.height or "flex"
    if type(width) == "number" then
        width = utils.resolve_width(width)
    elseif type(width) == "table" then
        width.min = utils.resolve_width(width.min or 0)
        width.max = utils.resolve_width(width.max or 1)
    end
    if type(height) == "number" then
        height = utils.resolve_height(height)
    elseif type(height) == "table" then
        height.min = utils.resolve_height(height.min or 0)
        height.max = utils.resolve_height(height.max or 1)
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
        state = {
            buf = -1,
            max_width = -1,
            max_height = -1,
        },
    }
    return setmetatable(display, Display)
end

---fails if update wasn't called as max_width/height are invalid
---@return integer row, integer col, integer width, integer height, string anchor
function Display:_get_rect()
    local width, height = self.width, self.height
    if width == "flex" then
        width = self.state.max_width
    elseif type(width) == "table" then
        width = utils.clamp(self.state.max_width, width.min, width.max)
    end
    if height == "flex" then
        height = self.state.max_height
    elseif type(height) == "table" then
        height = utils.clamp(self.state.max_height, height.min, height.max)
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

---@param items omb.source.Item[]
function Display:update(items)
    if not vim.api.nvim_buf_is_valid(self.state.buf) then
        self.state.buf = vim.api.nvim_create_buf(false, true)
        assert(self.state.buf ~= 0, "couldn't create buffer")
    end
    local buf = self.state.buf

    local lines = {}
    for _, item in ipairs(items) do
        local line = item.key .. self.key_separator .. item.text
        table.insert(lines, line)
        if self.state.max_width < #line then
            self.state.max_width = #line
        end
    end
    self.state.max_height = #lines

    -- clear the buffer (TODO: this shouldn't be done always, like when reusing cached values, once I add cache)
    vim.api.nvim_buf_clear_namespace(buf, core.state.ns, 0, -1)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    -- display lines
    vim.api.nvim_buf_set_lines(buf, 0, #lines, false, lines)

    for i, item in ipairs(items) do
        local text_start = #item.key + #self.key_separator
        for _, hl_range in ipairs(item.hl_ranges) do
            vim.api.nvim_buf_set_extmark(
                buf,
                core.state.ns,
                i - 1, -- 0-based
                text_start + hl_range[1],
                { end_col = text_start + hl_range[2], hl_group = hl_range[3] }
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
