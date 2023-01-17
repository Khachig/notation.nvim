vim.api.nvim_command("set rtp+=.")

local run_in_scratch_buffer = function(func, lines)
    local old_bufnr = vim.api.nvim_get_current_buf()
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)

    if lines ~= nil then
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
    end

    func()

    vim.api.nvim_set_current_buf(old_bufnr)
    vim.api.nvim_buf_delete(bufnr, {force=true})
end


describe("frontmatter.parse_tags", function()
    local fm = require("notation.frontmatter")

    it("returns empty table on empty string", function()
        local result = fm.parse_tags("")
        assert.are.same({}, result)
    end)

    it("returns empty table on empty tagtable", function()
        local result = fm.parse_tags("tags: ")
        assert.are.same({}, result)
    end)

    it("returns empty table on invalid input", function()
        local input_a, input_b = "one#, two three  ,, four", "fi ve_, # six , ##"
        local result_a, result_b = fm.parse_tags(input_a), fm.parse_tags(input_b)
        assert.are.same({}, result_a)
        assert.are.same({}, result_b)
    end)

    local compare_tags = function(expected, actual)
        for i, exp_result in ipairs(expected) do
            assert.equals(#expected[i], #actual[i])
            for j, exp_item in ipairs(exp_result) do
                assert.equals(exp_item, actual[i][j])
            end
        end
    end
    it("parses correct number of tags on valid input", function()
        local input_a, input_b, input_c = "#one, #two", "#three", "#four, #five, #six, #seven"
        local expected = {
            {"one", "two"},
            {"three"},
            {"four", "five", "six", "seven"}
        }
        local actual = {
            fm.parse_tags(input_a),
            fm.parse_tags(input_b),
            fm.parse_tags(input_c)
        }
        compare_tags(expected, actual)
    end)

    it("parses all valid tags in input with valid and invalid entries", function()
        local input_a, input_b = "#one  , two, #three", "#no spaces allowed, in tags, #this_is_fine"
        local expected = {
            {"one", "three"},
            {"this_is_fine"}
        }
        local actual = {
            fm.parse_tags(input_a),
            fm.parse_tags(input_b)
        }
        compare_tags(expected, actual)
    end)
end)

describe("frontmatter.stringify_tags", function()
    local fm = require("notation.frontmatter")

    it("returns empty string on empty input", function()
        assert.equal("", fm.stringify_tags({}))
    end)

    it("skips non-string items in input", function()
        assert.equal("#one, #three", fm.stringify_tags({"one", 2, "three"}))
    end)

    it("stringifies nested tables recursively", function()
        assert.equal("#one, #nested_one, #nested_two, #two", fm.stringify_tags({"one", {"nested_one", "nested_two"}, "two"}))
    end)
end)

describe("frontmatter.get_frontmatter", function()
    local fm = require("notation.frontmatter")

    it("returns empty table when buffer has no frontmatter", function()
        run_in_scratch_buffer(function()
            local result = fm.get_frontmatter()
            assert.are.same({}, result)
        end)
    end)

    it("returns table with start and end indices and empty data field when frontmatter exists but is empty", function()
        local lines = {
            "---",
            "---"
        }
        run_in_scratch_buffer(function()
            local result = fm.get_frontmatter()
            local expected = {fm_start=1, fm_end=2, data={}}
            assert.are.same(expected, result)
        end, lines)
    end)

    it("returns empty string or empty table when frontmatter keys don't have values", function()
        local lines = {
            "---",
            "date: ",
            "tags: ",
            "other_key: ",
            "---"
        }
        run_in_scratch_buffer(function()
            local result = fm.get_frontmatter()
            local expected = {
                fm_start=1, fm_end=5,
                data={
                    date="",
                    tags={},
                    other_key=""
                }
            }
            assert.are.same(expected, result)
        end, lines)
    end)

    it("returns table with correctly formatted and parsed data when frontmatter exists", function()
        local lines = {
            "---",
            "date: Saturday, Jan 14, 2023. 21:03.",
            "tags: #one, #two, #three",
            "other_key: some other data",
            "---"
        }
        run_in_scratch_buffer(function()
            local result = fm.get_frontmatter()
            local expected = {
                fm_start=1, fm_end=5,
                data={
                    date="Saturday, Jan 14, 2023. 21:03.",
                    tags={"one", "two", "three"},
                    other_key="some other data"
                }
            }
            assert.are.same(expected, result)
        end, lines)
    end)
end)

describe("frontmatter.write_frontmatter", function()
    local fm = require("notation.frontmatter")
    local mock = require("luassert.mock")
    local stub = require("luassert.stub")

    local set_lines
    before_each(function()
        set_lines = stub(vim.api, "nvim_buf_set_lines")
        set_lines.returns(nil)
    end)

    after_each(function()
        mock.revert(set_lines)
    end)

    it("sets frontmatter lines correctly", function()
        run_in_scratch_buffer(function()
            local frontmatter = {
                fm_start=1, fm_end=5,
                data={
                    tags={"one", "two", "three"},
                    date="Saturday, Jan 14, 2023. 21:03.",
                    other_key="some other data"
                }
            }
            local lines = {
                "---",
                "date: Saturday, Jan 14, 2023. 21:03.",
                "other_key: some other data",
                "tags: #one, #two, #three",
                "---"
            }
            table.sort(lines)
            local expected_called_args = {0, 0, 5, false, lines}
            fm.write_frontmatter(frontmatter)
            assert.stub(set_lines).was_called(1)

            local called_args = {unpack(set_lines.calls[1].refs, 1, 5)}
            table.sort(called_args[5])
            assert.are.same(expected_called_args, called_args)
        end)
    end)
end)
