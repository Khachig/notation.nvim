local function reset()
    package.loaded["notation"] = nil
    package.loaded["notation.main"] = nil
    package.loaded["dev"] = nil
end

CONFPATH = vim.fn.stdpath("data") .. "/notation-data"

local function setup()
    reset()
    os.execute("mv " .. CONFPATH .. " " .. CONFPATH .. ".bak 2> /dev/null")
    require("notation").setup({notes_dir="/tmp/Notes", default_keymaps=false})
end

local function teardown()
    reset()
    os.execute("rm -r /tmp/Notes 2> /dev/null")
    os.execute("rm " .. CONFPATH .. " 2> /dev/null")
    os.execute("mv " .. CONFPATH .. ".bak" .. " " .. CONFPATH)
end

vim.api.nvim_command("set rtp+=.")
vim.keymap.set("n", "<Space>RS", setup)
vim.keymap.set("n", "<Space>RR", teardown)
