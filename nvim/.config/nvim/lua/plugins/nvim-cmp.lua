return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- soource for file system paths
		"hrsh7th/cmp-nvim-lsp",
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
	},
	config = function()
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local lspkind = require("lspkind")
		lspkind.init({})

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping(function(fallback)
					-- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
					if cmp.visible() then
						local entry = cmp.get_selected_entry()
						if not entry then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						end
						cmp.confirm()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
			}),
			-- sources for autocompletion
			sources = cmp.config.sources({
				{ name = "path" },
				{ name = "nvim_lsp", keyword_length = 1 },
				{ name = "luasnip", keyword_length = 2 },
				{ name = "buffer", keyword_length = 3 },
				{ name = "codeium" },
				{ name = "copilot" },
			}),
			-- configure lspkind for vs-code like pictograms in completion menu
			formatting = {
				-- format = lspkind.cmp_format({
				-- 	mode = "symbol", -- show only symbol annotations
				-- 	maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
				-- 	-- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
				-- 	ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
				-- 	show_labelDetails = true, -- show labelDetails in menu. Disabled by default
				-- }),
				-- fields = { "kind", "abbr", "menu" },

				expandable_indicator = true,
				fields = { "abbr", "kind", "menu" },
				format = function(entry, vim_item)
					local icon = lspkind.presets.default[vim_item.kind]
					vim_item.kind = icon and (icon .. " " .. vim_item.kind) or "  " .. vim_item.kind

					-- Define menu shorthand for different completion sources.
					local menu_icon = {
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						buffer = "[Buffer]",
						path = "[Path]",
						copilot = "[Copilot]",
						codeium = "[Codeium]",
					}

					-- Set the menu "icon" to the shorthand for each completion source.
					vim_item.menu = menu_icon[entry.source.name] or ""

					vim_item.dup = ({
						nvim_lsp = 0,
						luasnip = 0,
					})[entry.source.name] or 0

					-- Set the fixed width of the completion menu to 60 characters.
					-- fixed_width = 20

					-- Set 'fixed_width' to false if not provided.
					fixed_width = fixed_width or false

					-- Get the completion entry text shown in the completion window.
					local content = vim_item.abbr

					-- Set the fixed completion window width.
					if fixed_width then
						vim.o.pumwidth = fixed_width
					end

					-- Get the width of the current window.
					local win_width = vim.api.nvim_win_get_width(0)

					-- Set the max content width based on either: 'fixed_width'
					-- or a percentage of the window width, in this case 20%.
					-- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
					local max_content_width = fixed_width and fixed_width - 10 or math.floor(win_width * 0.2)

					-- Truncate the completion entry text if it's longer than the
					-- max content width. We subtract 3 from the max content width
					-- to account for the "..." that will be appended to it.
					if #content > max_content_width then
						vim_item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 3) .. "..."
					else
						vim_item.abbr = content .. (" "):rep(max_content_width - #content)
					end
					return vim_item
				end,
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})
	end,
}
