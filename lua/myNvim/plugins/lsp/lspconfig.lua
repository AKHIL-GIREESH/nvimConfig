return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Import plugins
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- Initialize mason
		mason.setup()

		-- Configure mason-lspconfig
		mason_lspconfig.setup({
			ensure_installed = { "lua_ls", "graphql", "emmet_ls", "svelte" },
		})

		-- Capabilities for autocompletion
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Configure diagnostics symbols
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Handlers for specific servers
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({ capabilities = capabilities })
			end,
			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
								disable = { "spell", "lowercase-global", "spell-check" },
							},
						},
					},
				})
			end,
			["graphql"] = function()
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["emmet_ls"] = function()
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = { "html", "css", "javascriptreact", "typescriptreact", "svelte" },
				})
			end,
			["svelte"] = function()
				lspconfig["svelte"].setup({
					capabilities = capabilities,
				})
			end,
		})

		-- Keymaps for LSP functionality
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				-- Set keybinds
				vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})
	end,
}
