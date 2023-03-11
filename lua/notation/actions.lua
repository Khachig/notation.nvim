local fm = require("notation.frontmatter")
local utils = require("notation.utils")

Root, Inbox = utils.get_notes_dirs()

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
    local opts = utils.get_telescope_opts({
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
    utils.show_telescope_picker(notes, opts)
end

function M.tag_note()
    if vim.o.filetype ~= "markdown" then
        vim.notify("Can't tag non-markdown files.", "error")
        return
    end
    local tags = fm.get_all_tags()
    table.insert(tags, "New Tag")
    local opts = utils.get_telescope_opts({
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
    utils.show_telescope_picker(tags, opts)
end

function M.search_tags()
    local tags = fm.get_all_tags()
    local tag_opts = utils.get_telescope_opts({
        results_title="Tags",
        callback=function(selection)
            if selection ~= nil then
                local tag = selection[1]
                local opts = utils.get_telescope_opts({
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
    utils.show_telescope_picker(tags, tag_opts)
end

return M
