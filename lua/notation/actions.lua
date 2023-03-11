local fm = require("notation.frontmatter")
local utils = require("notation.utils")

local Root, Inbox

local function open_note(filename, opts)
    if filename:match("%.md$") == nil then
        filename = filename .. ".md"
    end
    local frontmatter = {
        fm_start = 1,
        fm_end = 1,
        data = {
            date= os.date("%A, %B %d, %Y. %H:%M."),
            tags= opts.tags or {}
        }
    }
    vim.api.nvim_command("e " .. Inbox:joinpath(filename).filename)
    fm.write_frontmatter(frontmatter)
end

local function get_all_notes()
    local inbox_notes = vim.fn.system("ls -l " .. Inbox.filename .. " | sed '/^[^\\-]/d' | rev | cut -d' ' -f1 | rev")
    local notes = {}
    for i in string.gmatch(inbox_notes, "([^\n]+)") do
        table.insert(notes, i)
    end
    return notes
end

local M = {}

function M.setup(opts)
    Root, Inbox = require("notation.utils").get_notes_dirs(opts.notes_dir)

    if opts.default_keymaps ~= false then
        vim.keymap.set("n", "<leader>nl", M.list_notes, {})
        vim.keymap.set("n", "<leader>nc", M.create_note, {})
        vim.keymap.set("n", "<leader>nj", M.create_journal_entry, {})
        vim.keymap.set("n", "<leader>nt", M.tag_note, {})
        vim.keymap.set("n", "<leader>ns", M.search_tags, {})
    end
end

function M.create_note(opts)
    local filename = vim.fn.input("Note name: ")
    if filename ~= "" then
        open_note(filename, opts or {})
    end
end

function M.create_journal_entry()
    M.create_note({tags={"journal"}})
end

function M.list_notes()
    local notes = get_all_notes()
    utils.show_telescope_picker(notes, {
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
end

function M.tag_note()
    if vim.o.filetype ~= "markdown" then
        vim.notify("Can't tag non-markdown files.", "error")
        return
    end
    local tags = fm.get_all_tags(Inbox)
    table.insert(tags, "New Tag")
    utils.show_telescope_picker(tags, {
        results_title="Tags",
        callback=function(selection)
            if selection ~= nil then
                local tag = selection[1]
                if tag == "New Tag" then
                    tag = vim.fn.input("New Tag: ")
                end
                fm.add_tag(tag)
            end
        end
    })
end

function M.search_tags()
    local tags = fm.get_all_tags(Inbox)
    utils.show_telescope_picker(tags, {
        results_title="Tags",
        callback=function(selection)
            if selection ~= nil then
                local tag = selection[1]
                local opts = utils.get_telescope_opts({
                    results_title="Notes tagged #" .. tag,
                    preview=true,
                    preview_root_path=Inbox,
                    search_dirs={Inbox.filename},
                    cwd=Inbox.filename,
                    default_text="#" .. tag
                })
                require("telescope.builtin").live_grep(opts)
            end
        end
    })
end

return M
