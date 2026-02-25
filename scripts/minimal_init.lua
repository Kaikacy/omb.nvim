-- Add cwd to 'runtimepath'
vim.opt.rtp:append(vim.fn.getcwd())

-- Only when calling headless neovim
if #vim.api.nvim_list_uis() == 0 then
    -- Add mini.test to 'runtimepath' and load it
    vim.opt.rtp:append(".tests/mini.test")
    require("mini.test").setup()
end
