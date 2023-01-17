local M = {}

function M.show_telescope_picker (picker_list, opts)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local previewer = require("telescope.previewers").new_buffer_previewer
    opts = opts or {}
    local preview
    if opts.preview then
        preview = previewer({
            define_preview=function(self, entry)
                conf.buffer_previewer_maker(opts.preview_root_path:joinpath(entry[1]).filename, self.state.bufnr, {
                    bufname = self.state.bufname,
                    winid = self.state.winid,
                })
            end
        })
    end
    pickers.new(opts, {
        results_title = opts.results_title,
        default_text= opts.default_text,
        finder = finders.new_table {
            results = picker_list
        },
        sorter = conf.generic_sorter(opts),
        previewer = preview
    }):find()
end

function M.get_telescope_opts(options)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local opts = {}

    if options.preview == nil then
        opts = require("telescope.themes").get_dropdown({})
    end

    for k, v in pairs(options) do
        opts[k] = v
    end

    if options.callback then
        opts.attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                options.callback(selection)
            end)
            return true
        end
    end

    return opts
end

return M
