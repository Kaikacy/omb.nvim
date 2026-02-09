local M = {}

---If 0 < width <= 1 then percives it as percentage, if width > 1 then it's column count, otherwise error
---@return integer cols
function M.resolve_width(width)
    if width > 0 and width <= 1 then
        return math.floor(vim.o.columns * width + 0.5)
    elseif width > 1 then
        return width
    else
        error("Argument must be non-negative")
    end
end

---If 0 < height <= 1 then percives it as percentage, if height > 1 then it's row count, otherwise error
---@return integer rows
function M.resolve_height(height)
    if height > 0 and height <= 1 then
        return math.floor(vim.o.lines * height + 0.5)
    elseif height > 1 then
        return height
    else
        error("Argument must be non-negative")
    end
end

---Clamps n between min and max, if min > max then error
---@param n number
---@param min number
---@param max number
---@return number
function M.clamp(n, min, max)
    assert(max >= min, "invalid min and max values")
    return math.max(math.min(n, max), min)
end

return M
