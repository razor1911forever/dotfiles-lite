local not_lightweight = not vim.g.lightweight

return {
  {
    -- "Jay-Madden/auto-fix-return.nvim",
    dir = "~/git/auto-fix-return.nvim",
    cond = not_lightweight,
    ft = { "go" },
    config = true,
    opts = {
      -- log_level = vim.log.levels.DEBUG,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = true,
    event = "VeryLazy",
  },
  {
    "catgoose/templ-goto-definition",
    cond = not_lightweight,
    ft = { "go", "templ" },
    config = true,
  },
  {
    "fredrikaverpil/godoc.nvim",
    cond = not_lightweight,
    ft = { "go" },
    version = "*",
    build = "go install github.com/lotusirous/gostdsym/stdsym@latest", -- optional
    cmd = { "GoDoc" },
    opts = {
      picker = {
        type = "telescope",
      },
    },
  },
}
