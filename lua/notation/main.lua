local Path = require("plenary.path")
local brain, tsc

Root = Path:new()
Inbox = Path:new()

local M = {}

function M.list_notes()
    local notes = brain.get_all_notes()
    local opts = tsc.get_telescope_opts({
        preview=true,
        preview_root_path=Inbox,
        results_title="My Notes",
        prompt_title="Search Notes",
        callback=function(selection)
            if selection ~= nil then
                vim.api.nvim_command("e " .. Inbox:joinpath(selection[1]).filename)
            end
        end
    })
    tsc.show_telescope_picker(notes, opts)
end

function M.create_note(opts)
    local filename = vim.fn.input("Note name: ")
    if filename ~= "" then
        brain.open_note(filename, opts or {})
    end
end

function M.create_journal_entry()
    M.create_note({tags={"journal"}})
end

function M.tag_note()
    if vim.o.filetype ~= "markdown" then
        vim.notify("Can't tag non-markdown files.", "error")
        return
    end
    local tags = brain.get_all_tags()
    table.insert(tags, "New Tag")
    local opts = tsc.get_telescope_opts({
        results_title="Tags",
        callback=function(selection)
            if selection ~= nil then
                local tag = selection[1]
                if tag == "New Tag" then
                    tag = vim.fn.input("New Tag: ")
                end
                brain.add_tag(tag)
            end
        end
    })
    tsc.show_telescope_picker(tags, opts)
end

function M.search_tags()
    local tags = brain.get_all_tags()
    local tag_opts = tsc.get_telescope_opts({
        results_title="Tags",
        callback=function(selection)
            if selection ~= nil then
                local tag = selection[1]
                local opts = tsc.get_telescope_opts({
                    results_title="Notes tagged #" .. tag,
                    preview=true,
                    preview_root_path=Inbox,
                    search_dirs={Inbox.filename},
                    default_text="#" .. tag
                })
                require("telescope.builtin").live_grep(opts)
            end
        end
    })
    tsc.show_telescope_picker(tags, tag_opts)
end

M.setup = function(opts)
    local options = opts or {}
    local config = Path:new(vim.fn.stdpath("data")):joinpath("notation-data")
    if config:exists() then
        local lines = vim.fn.readfile(config.filename)
        Root = Path:new(lines[1])
        Inbox = Path:new(lines[2])
    else
        Root = Path:new(vim.fn.expand(options.notes_dir) or vim.fn.expand("~/Notes"))
        Inbox = Root:joinpath("Inbox")
        vim.fn.writefile({Root.filename, Inbox.filename}, config.filename)
        vim.fn.mkdir(Inbox.filename, "p")
    end

    brain = require("notation.actions")
    tsc = require("notation.telescope-utils")

    local funcs = {}
    funcs.NTListNotes = M.list_notes
    funcs.NTCreateNote = M.create_note
    funcs.NTCreateJournalEntry = M.create_journal_entry
    funcs.NTTagNote = M.tag_note
    funcs.NTSearchTags = M.search_tags

    for command, func in pairs(funcs) do
        vim.api.nvim_create_user_command(command, func, {})
    end

    if options.default_keymaps ~= false then
        vim.api.nvim_set_keymap("n", "<leader>nl", M.list_notes, {})
        vim.api.nvim_set_keymap("n", "<leader>nc", M.create_note, {})
        vim.api.nvim_set_keymap("n", "<leader>nj", M.create_journal_entry, {})
        vim.api.nvim_set_keymap("n", "<leader>nt", M.tag_note, {})
        vim.api.nvim_set_keymap("n", "<leader>ns", M.search_tags, {})
    end
end

return M
