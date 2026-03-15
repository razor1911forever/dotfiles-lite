local u = require("util")
local m = u.lazy_map

local not_lightweight = not vim.g.lightweight

return {
  {
    "mfussenegger/nvim-dap",
    cond = not_lightweight,
    keys = {
      m("<F1>", [[DapStepInto]]),
      m("<F2>", [[DapStepOver]]),
      m("<F3>", [[DapStepOut]]),
      m("<F4>", [[DapStepBack]]),
      m("<F5>", [[DapContinue]]),
      ---
      m("<F8>", [[DapStepInto]]),
      m("<F9>", [[DapStepOver]]),
      m("<F10>", [[DapStepOut]]),
      ---
      m("<F12>", [[DapDisconnect]]),
    },
    cmd = { "DapContinue" },
    config = function()
      local dap = require("dap")
      require("config.dap.keymaps").setup(dap)
      require("config.dap.adapters").setup(dap)
    end,
    dependencies = {
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "ofirgall/goto-breakpoints.nvim",
      "Weissle/persistent-breakpoints.nvim",
      "jbyuki/one-small-step-for-vimkind",
    },
    lazy = true,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    cond = not_lightweight,
    opts = {
      ensure_installed = {
        "bash",
        "delve",
        "js",
      },
      automatic_installation = true,
      automatic_setup = true,
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    cond = not_lightweight,
    config = true,
    lazy = true,
  },
  {
    "ofirgall/goto-breakpoints.nvim",
    cond = not_lightweight,
    keys = {
      m("]r", [[lua require('goto-breakpoints').next()]]),
      m("[r", [[lua require('goto-breakpoints').prev()]]),
    },
    lazy = true,
  },
  -- TODO: 2025-08-03 - persistent breakpoints is not working
  {
    "Weissle/persistent-breakpoints.nvim",
    cond = not_lightweight,
    opts = {
      load_breakpoints_event = { "BufReadPre" },
    },
    keys = {
      m("<leader>/", [[lua require('persistent-breakpoints.api').toggle_breakpoint()]]),
      m("<F11>", [[lua require('persistent-breakpoints.api').clear_all_breakpoints()]]),
    },
    lazy = true,
  },
  {
    "igorlfs/nvim-dap-view",
    cond = not_lightweight,
    opts = {
      winbar = {
        show = true,
        sections = {
          "watches",
          "scopes",
          "breakpoints",
          "threads",
          "repl",
        },
        default_section = "breakpoints",
      },
      windows = {
        height = 12,
        terminal = {
          position = "right",
        },
      },
      help = {
        border = "rounded",
      },
    },
    cmd = {
      "DapViewOpen",
      "DapViewClose",
      "DapViewToggle",
      "DapViewWatch",
    },
    keys = {
      m("<leader>?", [[lua require("dap-view").toggle(true)]]),
    },
    lazy = true,
  },
}
