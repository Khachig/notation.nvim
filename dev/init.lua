vim.api.nvim_command("set rtp+=.")
package.loaded["notation"] = nil
package.loaded["notation.main"] = nil
package.loaded["dev"] = nil

require("notation").setup({notes_dir="/tmp/Notes", default_keymaps=false})

vim.api.nvim_set_keymap("n", "<Space>R", ":luafile dev/init.lua<CR>", {})
