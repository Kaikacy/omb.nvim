local H = {}

function H.test_set_with_child(module)
    local child = MiniTest.new_child_neovim()
    local T = MiniTest.new_set({
        hooks = {
            pre_case = function()
                child.restart({ "-u", "scripts/minimal_init.lua" })
                child.lua(('M = require("%s")'):format(module))
            end,
            post_once = child.stop,
        },
    })
    return T, child
end

H.expect = MiniTest.expect
H.eq = MiniTest.expect.equality

return H
