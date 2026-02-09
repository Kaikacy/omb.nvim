if vim.g.loaded_omb == 1 then
    return
end
vim.g.loaded_omb = 1

local omb = require("omb")

_ = omb
