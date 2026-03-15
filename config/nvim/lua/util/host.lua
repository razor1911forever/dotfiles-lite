local M = {}

-- Lightweight mode disables LSP, Mason, DAP, linting, formatting, and other
-- heavy plugins so neovim stays fast on remote/low-resource hosts.
--
-- Enable it:  export NVIM_LIGHTWEIGHT=1

M.lightweight = os.getenv("NVIM_LIGHTWEIGHT") == "1"
vim.g.lightweight = M.lightweight

-- Plugins to skip in lightweight mode (matched against lazy.nvim plugin.name)
M.disabled_plugins = {
  -- LSP
  "nvim-lspconfig",
  "lsp-lens.nvim",
  "lspkind-nvim",
  "lazydev.nvim",
  -- Completion
  "nvim-cmp",
  -- Formatting / Linting
  "conform.nvim",
  "mason-conform.nvim",
  "nvim-lint",
  -- DAP
  "nvim-dap",
  "mason-nvim-dap.nvim",
  "nvim-dap-virtual-text",
  "goto-breakpoints.nvim",
  "persistent-breakpoints.nvim",
  "nvim-dap-view",
  -- Testing
  "neotest",
  -- AI
  "supermaven-nvim",
  -- Language-specific
  "auto-fix-return.nvim",
  "templ-goto-definition",
  "godoc.nvim",
  -- Database
  "vim-dadbod-ui",
  -- Treesitter extras
  "nvim-ts-context-commentstring",
}

return M
