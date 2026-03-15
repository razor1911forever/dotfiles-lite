local config = function()
  require("lspkind").init({
    mode = "symbol_text",
    preset = "default",
    symbol_map = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Field = "ﰠ",
      Variable = "",
      Class = "ﴯ",
      Interface = "",
      Module = "",
      Property = "ﰠ",
      Unit = "塞",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "פּ",
      Event = "",
      Operator = "",
      TypeParameter = "",
      Copilot = "",
      Supermaven = "",
    },
  })
end

return {
  "onsails/lspkind-nvim",
  cond = not vim.g.lightweight,
  config = config,
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/nvim-cmp",
  },
  lazy = true,
}
