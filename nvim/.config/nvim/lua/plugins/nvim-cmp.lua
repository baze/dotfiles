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

		local ELLIPSIS_CHAR = "…"
		local MAX_LABEL_WIDTH = 20
		local MIN_LABEL_WIDTH = 20

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
				{ name = "buffer", keyword_length = 3 },
				{ name = "luasnip", keyword_length = 2 },
				{ name = "codeium" },
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
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					vim_item.kind = lspkind.presets.default[vim_item.kind] or ""
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[LuaSnip]",
						buffer = "[Buffer]",
						path = "[Path]",
						codium = "[Codeium]",
					})[entry.source.name]
					local label = vim_item.abbr
					local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
					if truncated_label ~= label then
						vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
					elseif string.len(label) < MIN_LABEL_WIDTH then
						local padding = string.rep(" ", MIN_LABEL_WIDTH - string.len(label))
						vim_item.abbr = label .. padding
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
