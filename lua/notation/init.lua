local notation = require("notation.actions")

local function setup(opts)
    require("notation.utils").get_notes_dirs(opts.notes_dir)

    if opts.default_keymaps ~= false then
        vim.keymap.set("n", "<leader>nl", notation.list_notes, {})
        vim.keymap.set("n", "<leader>nc", notation.create_note, {})
        vim.keymap.set("n", "<leader>nj", notation.create_journal_entry, {})
        vim.keymap.set("n", "<leader>nt", notation.tag_note, {})
        vim.keymap.set("n", "<leader>ns", notation.search_tags, {})
    end
end

return {
    setup = setup,
    create_note = notation.create_note,
    create_journal_entry = notation.create_journal_entry,
    list_notes = notation.list_notes,
    tag_note = notation.tag_note,
    search_tags = notation.search_tags
}
