-- API will probably change

local omb = require("omb")
local assigners = require("omb.builtin").assigners
local handlers = require("omb.builtin").handlers
-- this may be better idea to only load whats needed
-- local handlers = require("omb.builtin.handlers")

-- all of this might have pre and post callbacks

local buf_source = omb.source({
    -- `ctx contains information about config, provider options
    -- `my` is rw table, which can be used to pass data
    -- from top to bottom, throughout pipeline.
    -- no component will touch it, it's soley for the user
    provider = function(ctx, my)
        _ = ctx
        if my.hidden then
            print("hidden was passed")
        end
        return vim.api.nvim_list_bufs()
    end,
    -- sorter is optional
    sorter = function(ctx)
        -- sort numerically
        return vim.fn.sort(ctx.list, "n")
    end,
    formatter = function(ctx)
        return vim.tbl_map(function(buf)
            return vim.api.nvim_buf_get_name(buf)
        end, ctx.list)
    end,
    assigner = function(ctx)
        -- key -> value
        -- also should handle key conflicts

        -- use builtin first letter assigner
        -- when formatted is false, uses raw list instead
        return assigners.first_letter(ctx, {
            formatted = true,
            prefer_lowercase = true,
        })
    end,
})

local generic_drawer = omb.drawer({
    mode = "window",
    window_opts = {},
    key_separator = " | ",
})

local generic_handler = omb.handler({
    cancel_key = "<esc>",
    handle_interupt = true, -- use error_handler for <C-c>
    handle_action_error = true, -- handle any action error
    action = function(ctx, my)
        _ = my
        return handlers.buf_switch(ctx, {
            split = "vertical",
        })
    end,
    -- error handler
    -- - when key coudn't be found
    -- - interupt only if `handle_interupt` is true
    -- - action errors if `handle_action_error` is true
    -- ...
    on_error = function(ctx)
        vim.print(ctx.error)
    end,
})

local buf_switcher = omb.selector(buf_source, generic_drawer, generic_handler)
-- this could also work, gives less control but is simpler
-- local buf_switcher = omb.selector({source = { -- source opts }, drawer = {}, ... })

buf_switcher.open({ hidden = true }) -- content of `my` table when starting up
