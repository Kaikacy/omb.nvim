local core = require("omb.core")
local utils = require("omb.utils")

---@class omb.Selector
---@field list omb.selector.list
---@field format omb.selector.format
---@field opts omb.selector.Opts
---@field state omb.selector.State
local Selector = {}
Selector.__index = Selector

---@param config omb.selector.PartialConfig
---@return omb.Selector
function Selector.new(config)
    local ypos, xpos = unpack(vim.fn.split(config.pos or "center_center", "_"))
    local buf = vim.api.nvim_create_buf(false, true)
    assert(buf ~= 0, "Buffer creation failed")

    ---@type omb.Selector
    local selector = {
        list = config.list,
        format = config.format or function(item)
            return { tostring(item.value) }
        end,
        opts = {
            validate_list = config.validate_list or false,
            xpos = xpos,
            ypos = ypos,
            width = config.width or { 0, 1 },
            height = config.height or { 0, 1 },
            key_separator = config.key_separator or " | ",
            extends_char = config.extends_char or "+",
        },
        state = {
            buf = buf,
            exact_width = -1,
            exact_height = -1,
        },
    }
    return setmetatable(selector, Selector)
end

---@package
---@return vim.api.keyset.win_config
function Selector:_get_win_config()
    local out = {
        relative = "editor",
        style = "minimal",
        focusable = false,
        zindex = 90,
    }
    out.width, out.height = self.opts.width, self.opts.height
    if type(out.width) == "number" then
        out.width = utils.resolve_width(out.width)
    elseif type(out.width) == "table" then
        out.width =
            utils.clamp(self.state.exact_width, utils.resolve_width(out.width[1]), utils.resolve_width(out.width[2]))
    end
    if type(out.height) == "number" then
        out.height = utils.resolve_config.height(out.height)
    elseif type(out.height) == "table" then
        out.height = utils.clamp(
            self.state.exact_height,
            utils.resolve_config.height(out.height[1]),
            utils.resolve_config.height(out.height[2])
        )
    end

    -- Center by default
    out.row, out.col = bit.rshift(vim.o.lines - out.height, 1), bit.rshift(vim.o.columns - out.width, 1)
    local yanchor, xanchor = "N", "W"
    if self.opts.ypos == "top" then
        out.row = 0
    elseif self.opts.ypos == "bottom" then
        yanchor = "S"
        out.row = vim.o.lines
    end
    if self.opts.xpos == "left" then
        out.col = 0
    elseif self.opts.xpos == "right" then
        xanchor = "E" -- East
        out.col = vim.o.columns
    end
    out.anchor = yanchor .. xanchor
    return out
end

-- TODO: add separate function for updating, showing...

---@param data table User data
function Selector:run(data)
    -- `data` table is passed by reference, unless it is reassigned by user, then it gets copied
    if core.state.is_active then
        utils.notify("Another selector is active", vim.log.levels.ERROR)
        -- TODO: logging
        return
    end
    core.state.is_active = true

    local items = self.list(data)

    if self.opts.validate_list then
        -- TODO
    end

    local lines = {}
    ---@cast items omb.item.Full[]
    for i, item in ipairs(items) do
        local fmt_item = self.format(item, i, data)
        item.text, item.hl_ranges = utils.fmt_item_to_pair(fmt_item)
        -- TODO: validate item if validate_list option is enabled

        local line = item.key .. self.opts.key_separator .. item.text
        table.insert(lines, line)
        if self.state.exact_width < #line then
            self.state.exact_width = #line
        end
    end
    self.state.exact_height = #lines

    -- Using 2 for-loops and single call to buf_set_lines is faster than calling it on each iteration
    vim.api.nvim_buf_set_lines(self.state.buf, 0, -1, false, lines)
    for i, item in ipairs(items) do
        local text_start = #item.key + #self.opts.key_separator
        for _, hl_range in ipairs(item.hl_ranges) do
            vim.api.nvim_buf_set_extmark(
                self.state.buf,
                core.state.ns,
                i - 1, -- 0-based
                text_start + hl_range[1],
                { end_col = text_start + hl_range[2], hl_group = hl_range[3] }
            )
        end
    end

    local win = vim.api.nvim_open_win(self.state.buf, false, self:_get_win_config())
    vim.wo[win].wrap = false
    vim.wo[win].list = true
    vim.wo[win].listchars = "extends:" .. self.opts.extends_char
    core.state.win = win

    -- TODO: Handler

    core.state.is_active = false
end

return Selector
