local M = {}

-- Lightweight mode disables LSP, Mason, DAP, linting, formatting, and other
-- heavy plugins so neovim stays fast on remote/low-resource hosts.
--
-- Enable it:  export NVIM_LIGHTWEIGHT=1

M.lightweight = os.getenv("NVIM_LIGHTWEIGHT") == "1"
vim.g.lightweight = M.lightweight

return M
