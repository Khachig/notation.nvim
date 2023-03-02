vim.api.nvim_command("set rtp+=.")
local data_path = vim.fn.stdpath("data")

local Path = require("plenary.path")
local CONFIG = Path:new(vim.fn.stdpath("data")):joinpath("notation-data")
local BACKUP = Path:new(vim.fn.stdpath("data")):joinpath("notation-data.bak")

local function clean_setup()
    package.loaded["notation"] = nil
    vim.fn.system("rm -rf /tmp/Notes")
    vim.fn.system("mkdir -p /tmp/Notes/Inbox")
    if CONFIG:exists() then
        vim.fn.system("mv " .. CONFIG.filename .. " " .. BACKUP.filename)
    end
end

local function restore_setup()
    vim.fn.system("rm " .. CONFIG.filename)
    if BACKUP:exists() then
        vim.fn.system("mv " .. BACKUP.filename .. " " .. CONFIG.filename)
    end
end

describe("notation.setup", function()
    local nsb

    before_each(function()
        clean_setup()
        nsb = require("notation")
    end)

    after_each(function()
        restore_setup()
    end)

    it("sets root path", function()
        nsb.setup({
            notes_dir="/tmp/Notes",
        })

        local notes_paths = vim.fn.readfile(data_path .. "/notation-data")
        local root, inbox = notes_paths[1], notes_paths[2]
        assert.equals("/tmp/Notes", root)
        assert.equals("/tmp/Notes/Inbox", inbox)
    end)
end)
