local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Basic Settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.python3_host_prog = vim.fn.system("pyenv which python"):gsub("%s*$", "")
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.o.background = "dark"

-- Editor Options
vim.opt.number = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.hlsearch = true
vim.opt.timeoutlen = 300
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.softtabstop = 4 -- Number of spaces for a tab while editing
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.expandtab = true
-- Basic Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Plugin Specifications
require("lazy").setup({
	-- Syntax and Language Support
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},

	-- Theme and UI
	{ "Mofiqul/vscode.nvim" },
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
	{
		"j-hui/fidget.nvim",
		opts = {},
	},

	-- Editor Enhancement
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {},
	},
	"tpope/vim-sleuth",

	-- Code Manipulation
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	"windwp/nvim-ts-autotag",

	-- Project Management
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	"nvim-lua/plenary.nvim",
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
	},

	-- LSP and Completion
	{
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
	},
	"mason-org/mason-registry",

	-- Formatting
	{
		"stevearc/conform.nvim",
		opts = {},
	},
})

-- Theme Configuration
require("vscode").setup({
	color_overrides = {
		vscBack = "#000000",
	},
})
vim.cmd.colorscheme("vscode")

-- Plugin Configurations
-- Autotag
require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
	per_filetype = {
		["html"] = {
			enable_close = false,
		},
	},
})

-- Indent Lines
require("ibl").setup()

-- Status Line
require("lualine").setup({
	sections = {
		lualine_x = { "overseer" },
	},
})

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"html",
		"scss",
		"css",
		"lua",
		"luadoc",
		"markdown",
		"vim",
		"vimdoc",
		"javascript",
		"vue",
		"python",
	},
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = { "ruby" },
	},
	indent = {
		enable = true,
		disable = { "ruby" },
	},
})

require("telescope").setup({
	pickers = {
		buffers = {
			mappings = {
				n = {
					["d"] = "delete_buffer",
				},
			},
		},
	},
})
-- Telescope Keybindings
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- Diagnostic Keymaps
vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>")
vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

-- LSP Configuration
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
	end,
})

-- LSP Server Setup
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local default_setup = function(server)
	require("lspconfig")[server].setup({
		capabilities = lsp_capabilities,
	})
end

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "volar" },
})

-- LSP Server Handlers
require("mason-lspconfig").setup_handlers({
	default_setup,
	["volar"] = function()
		require("lspconfig").volar.setup({
			filetypes = { "typescript", "javascript", "javascriptreact", "vue" },
			init_options = {
				vue = {
					hybridMode = false,
				},
			},
		})
	end,
	-- ["ts_ls"] = function()
	-- 	local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
	-- 	local volar_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"
	-- 	require("lspconfig").ts_ls.setup({
	-- 		init_options = {
	-- 			plugins = {
	-- 				{
	-- 					name = "@vue/typescript-plugin",
	-- 					location = volar_path,
	-- 					languages = { "vue" },
	-- 				},
	-- 			},
	-- 		},
	-- 	})
	-- end,
})

-- Completion Setup
local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
	},
	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
})

-- Formatting Setup
require("conform").setup({
	formatters_by_ft = {
		python = { "isort", "black" },
		javascript = { "prettier", stop_after_first = true },
		typescript = { "prettier" },
		vue = { "prettier" },
		lua = { "stylua" },
	},
	format_on_save = {
		timeout_ms = 2500,
		lsp_fallback = true,
	},
})

-- Format Commands
local function format_current_buffer()
	require("conform").format({
		bufnr = vim.api.nvim_get_current_buf(),
	})
end

vim.keymap.set("n", "<leader>cf", format_current_buffer, { noremap = true, silent = true })

-- Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
