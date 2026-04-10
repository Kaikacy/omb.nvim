local M = {}

---If 0 < width <= 1 then percives it as percentage, if width > 1 then it's column count, otherwise error
---@return integer cols
function M.resolve_width(width)
    if width > 0 and width <= 1 then
        return vim.fn.round(vim.o.columns * width)
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
        return vim.fn.round(vim.o.lines * height)
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

---Resolves and clamps width between min and max
---@param width number
---@param min number
---@param max number
---@return number
function M.clamp_width(width, min, max)
    return M.clamp(M.resolve_width(width), M.resolve_width(min), M.resolve_width(max))
end

---Resolves and clamps height between min and max
---@param height number
---@param min number
---@param max number
---@return number
function M.clamp_height(height, min, max)
    return M.clamp(M.resolve_height(height), M.resolve_height(min), M.resolve_height(max))
end

---Returns first duplicate in a list or nil if there aren't any
---@generic T
---@param list T[]
---@return T?
function M.get_first_dup(list)
    local seen = {}
    for _, v in ipairs(list) do
        if seen[v] then
            return v
        end
        seen[v] = true
    end
    return nil
end

---Zips two lists and returns iterator to use in for loop (idx, elem1, elem2)
---Doesn't check list size
---@generic T, U, V
---@param list1 T[]
---@param list2 U[]
---@return fun(): integer, T, U
function M.zip_iter(list1, list2)
    local i = 0
    local n = math.min(#list1, #list2)
    return function()
        i = i + 1
        if i > n then
            return nil
        end
        return i, list1[i], list2[i]
    end
end

---Zips three lists and returns iterator to use in for loop (idx, elem1, elem2, elem3)
---Doesn't check list size
---@generic T, U, V
---@param list1 T[]
---@param list2 U[]
---@param list3 V[]
---@return fun(): integer, T, U, V
function M.zip_iter3(list1, list2, list3)
    local i = 0
    local n = math.min(#list1, #list2, #list3)
    return function()
        i = i + 1
        if i > n then
            return nil
        end
        return i, list1[i], list2[i], list3[i]
    end
end

return M
