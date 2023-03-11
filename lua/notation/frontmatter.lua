local M = {}

local function parse_tags(tagstring)
    local tags = {}
    -- There is no alternation mechanism in lua pattern matching
    -- so we have to check alternatives separately.
    -- Alternatives ensure no spaces are allowed in tags
    for tag in string.gmatch(tagstring, "%#([%w%-_%/]+) *,") do
        table.insert(tags, tag)
    end
    for tag in string.gmatch(tagstring, "%#([%w%-_%/]+)$") do
        table.insert(tags, tag)
    end
    return tags
end

local function stringify_tags(taglist)
    local tagstring = ""
    local sep
    for i, tag in ipairs(taglist) do
        if i == 1 then
            sep = "#"
        else
            sep = ", #"
        end
        if type(tag) == "string" then
            tagstring = tagstring .. sep .. tag
        elseif type(tag) == "table" then
            tagstring = tagstring .. ", " .. stringify_tags(tag)
        end
    end
    return tagstring
end

function M.get_all_tags()
    local tagstrings = vim.fn.system("head -5 " .. Inbox:joinpath("*").filename .. " | sed -n '/^tags/p' | sed 's/^tags: \\+//' | sed 's/, /\\n/g' | tr -d '#' | sort | uniq")
    local tags = {}
    for i in string.gmatch(tagstrings, "([^\n]+)") do
        table.insert(tags, i)
    end
    return tags
end

function M.add_tag(new_tag)
    local frontmatter = M.get_frontmatter()
    table.insert(frontmatter.data.tags, new_tag)
    M.write_frontmatter(frontmatter)
end

function M.get_frontmatter()
    local cursor_pos = vim.fn.getcurpos()
    vim.fn.cursor(1, 1)
    local fm_start = vim.fn.search("---", "c")
    local fm_end = vim.fn.search("---")
    if fm_start == 0 then
        return {}
    end
    local fm_lines = vim.api.nvim_buf_get_lines(0, fm_start, fm_end - 1, false)
    local frontmatter = {fm_start=fm_start, fm_end=fm_end, data={}}
    for _, line in ipairs(fm_lines) do
        local key = string.match(line, "^([%w%p]+):")
        local value = string.match(line, "^[%w%p]+: (.+)$")
        if key == "tags" then
            if value ~= nil then
                value = parse_tags(value)
            else
                value = {}
            end
        end
        frontmatter.data[key] = value or ""
    end
    vim.fn.cursor(cursor_pos[2], cursor_pos[3])
    return frontmatter
end

function M.write_frontmatter(frontmatter)
    local lines = {"---"}
    for key, val in pairs(frontmatter.data) do
        local value = val
        if key == "tags" then
            value = stringify_tags(value)
        end
        table.insert(lines, key .. ": " .. value)
    end
    table.insert(lines, "---")
    vim.api.nvim_buf_set_lines(0, frontmatter.fm_start - 1, frontmatter.fm_end, false, lines)
end

return M
