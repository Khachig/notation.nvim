vim.api.nvim_command("set rtp+=.")
local data_path = vim.fn.stdpath("data")

local function clean_setup()
    package.loaded["notation"] = nil
    vim.fn.system("rm -rf /tmp/Notes")
    vim.fn.system("mkdir -p /tmp/Notes/Inbox")
end

describe("notation.setup", function()
    local nsb

    before_each(function()
        clean_setup()
        nsb = require("notation")
    end)

    it("sets root path", function()
        nsb.setup({
            notes_root="/tmp/Notes/",
            notes_inbox="/tmp/Notes/Inbox/"
        })

        local notes_paths = vim.fn.readfile(data_path .. "/notation-data")
        local root, inbox = notes_paths[1], notes_paths[2]
        assert.equals("/tmp/Notes", root)
        assert.equals("/tmp/Notes/Inbox", inbox)
    end)
end)
