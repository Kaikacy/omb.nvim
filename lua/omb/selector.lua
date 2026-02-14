---@class omb.Selector
local Selector = {}

---@return omb.Selector
function Selector:new()
    ---@type omb.Selector
    local selector = {}
    return setmetatable(selector, { __index = self })
end

function Selector:update() end
function Selector:open() end
function Selector:run() end
function Selector:stop() end

return Selector
