return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")
        fzf.register_ui_select()

        -- Basic setup (customize as desired)
        fzf.setup {
            winopts = {
                height = 0.9,
                width = 0.9,
                preview = { default = "bat" },
            },
            keymap = {
                builtin = {
                    ["<C-d>"] = "preview-page-down",
                    ["<C-u>"] = "preview-page-up",
                },
                fzf = {
                    ["ctrl-d"] = "preview-page-down",
                    ["ctrl-u"] = "preview-page-up",
					["ctrl-a"] = "toggle-all",
					["ctrl-q"] = "select-all+accept",
                },
            }
        }

        -- Keybindings
        vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "List buffers" })
        vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Help tags" })
        vim.keymap.set("n", "<leader>fl", fzf.grep_curbuf, { desc = "Grep current buffer" })
        vim.keymap.set("n", "<leader>fc", fzf.git_commits, { desc = "Git commits" })
        vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "LSP document symbols" })
        -- vim.keymap.set("n", "<leader>ft", fzf.file_browser, { desc = "File browser" })
        vim.keymap.set("n", "<leader>fn", function()
            fzf.files({ cwd = vim.fn.stdpath("config") })
        end)
        vim.keymap.set("n", "<leader>fp", function()
            fzf.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
        end)
        vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })
        vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })

        -- Custom multigrep function: prompt for a file regex, filter files, then grep in them
        local function multigrep()
            local rg = "rg --files"
            vim.ui.input({ prompt = "File regex: " }, function(file_pat)
                if not file_pat or #file_pat == 0 then return end
                local handles = vim.system({ "rg", "--files" }, { text = true }):wait()
                if not handles.code == 0 then
                    vim.notify("ripgrep failed", vim.log.levels.ERROR)
                    return
                end
                local files = {}
                for file in handles.stdout:gmatch("[^\r\n]+") do
                    if file:match(file_pat) then
                        table.insert(files, file)
                    end
                end
                if #files == 0 then
                    vim.notify("No files match" , vim.log.levels.INFO)
                    return
                end
                fzf.live_grep({ search_dirs = files })
            end)
        end

        vim.keymap.set("n", "<leader>fm", multigrep, { desc = "Multigrep (regex file filter)" })
    end,
}
