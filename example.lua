-- API will probably change

local omb = require("omb")
local assigners = require("omb.builtin").assigners
local handlers = require("omb.builtin").handlers
-- this may be better idea to only load whats needed
-- local handlers = require("omb.builtin.handlers")

-- all of this might have pre and post callbacks

-- provider, formatter and assigner can be combined into a single function, but they are seperated so that
-- caching will be more effective (TODO: once I add it): if newly provided list hasn't changed, no further processing will by done
-- some config option should control caching behavour, like force update...
---@type omb.Source.Config
local buf_source = {
    -- `ctx` will contains info like raw list, formatted list... (for provider function, it's empty)
    -- `my` is a shared RW table, for passing data from top to bottom, throughout the whole pipeline
    -- this way different components (and subcomponents) can communicate, one way (source -> drawer -> handler)
    -- nothing will ever touch it, it's soley for the user
    provider = function(ctx, my)
        _ = ctx
        if my.hidden then
            print("hidden was passed")
        end
        return vim.api.nvim_list_bufs()
    end,
    -- formatter is optional (might change), by default maps each element in ctx.list to string with tostring builtin
    formatter = function(ctx)
        return vim.tbl_map(function(buf)
            return vim.api.nvim_buf_get_name(buf)
        end, ctx.list)
    end,
    -- probably the most important procedure, to assign keys to items
    -- returns two tables, 1.key-value pairs and 2.list of keys used to determine the order they will be displayed
    -- after this function, validator is run to check if two returned tables are compatible
    assigner = function(ctx)
        -- use builtin first letter assigner
        -- when formatted is false, uses raw list instead
        return assigners.first_letter(ctx, {
            formatted = true,
            prefer_lowercase = true,
        })
    end,
}

---@type omb.Drawer.Config
local generic_drawer = {
    key_separator = " | ",
    -- smart position parsing, allows 8 general direction and center_center is the default
    pos = "center_right",
    -- uses exact width needed to fully display longest line, no limits
    width = "flex",
    -- width/height resolver inspired by telescope.nvim
    -- between (0; 1] used as percentage, >1 as columns/rows
    -- similar to "flex", but with optional lower and or upper limit to clamp the value
    height = { min = 0.1, max = 0.5 },
    -- iterator for each line
    -- can only highlight part after key and separator
    -- `ctx` provides info for current line, like item and key
    -- returns either list of hl ranges as shown, or single string which is hl group used for whole line (excluding starting part)
    -- range is 0-based, end-exclusive
    highlight = function(ctx, my)
        return {
            -- highlight to the end with 'Special' hl group, starting from second letter (0-based)
            { start_col = 1, end_col = #ctx.item, hl = "Special" },
        }
    end,
}

-- FIXME: handler api will change and this config does't reflect it's current state as there is no "state"
-- handles everything from user input to any kind of error that may occur throughout the pipeline
-- also either executes action or just returns result (probabaly former one)
-- handler is least developed component, lots of things might change, altho I do have it planned
---@type omb.Handler.Config
local generic_handler = {
    -- TODO: some sort of handler function[s] (maybe seperated) for all kinds of errors
    -- including interupts, errors during action execution and component errors

    -- key[s] used to stop selector (TODO: rename, maybe)
    cancel_key = "<esc>",
    handle_interupt = true, -- use error_handler for <C-c>
    handle_action_error = true,
    action = function(ctx, my)
        _ = my
        return handlers.buf_switch(ctx, {
            split = "vertical",
        })
    end,
    -- TODO: probably not how it would work, we'll see
    -- error handler
    -- - when key coudn't be found
    -- - interupt only if `handle_interupt` is true
    -- - action errors if `handle_action_error` is true
    -- ...
    on_error = function(ctx)
        vim.print(ctx.error)
    end,
}

local buf_switcher = omb.selector(buf_source, generic_drawer, generic_handler)
buf_switcher.run({ hidden = true }) -- content of `my` table when starting up
