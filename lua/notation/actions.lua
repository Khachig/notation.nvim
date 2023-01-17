local Path = require("plenary.path")
local data_path = Path:new(vim.fn.stdpath("data")):joinpath("notation-data")
local notes_paths = vim.fn.readfile(data_path.filename)
local fm = require("notation.frontmatter")

Root = Path:new(notes_paths[1])
Inbox = Path:new(notes_paths[2])

local M = {}

function M.add_tag(new_tag)
    local frontmatter = fm.get_frontmatter()
    print("Got frontmatter: " .. vim.inspect(frontmatter))
    table.insert(frontmatter.data.tags, new_tag)
    fm.write_frontmatter(frontmatter)
end

function M.open_note(filename, opts)
    if filename:match("%.md$") == nil then
        filename = filename .. ".md"
    end
    local options = opts or {}
    local frontmatter = {
        fm_start = 1,
        fm_end = 1,
        data = {
            date= os.date("%A, %B %d, %Y. %H:%M."),
            tags= options.tags or {}
        }
    }
    vim.api.nvim_command("e " .. Inbox:joinpath(filename).filename)
    fm.write_frontmatter(frontmatter)
end

function M.get_all_notes()
    local inbox_notes = vim.fn.system("ls -l " .. Inbox.filename .. " | sed '/^[^\\-]/d' | rev | cut -d' ' -f1 | rev")
    local notes = {}
    for i in string.gmatch(inbox_notes, "([^\n]+)") do
        table.insert(notes, i)
    end
    return notes
end

function M.get_all_tags()
    local tagstrings = vim.fn.system("head -5 " .. Inbox:joinpath("*").filename .. " | sed -n '/^tags/p' | sed 's/^tags: \\+//' | sed 's/, /\\n/g' | tr -d '#' | sort | uniq")
    local tags = {}
    for i in string.gmatch(tagstrings, "([^\n]+)") do
        table.insert(tags, i)
    end
    return tags
end

return M
