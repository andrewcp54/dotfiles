return {
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    keys = { { "<leader>o", "<cmd>Oil<cr>", desc = "Oil" } },
    config = function()
      require("oil").setup({})
    end,
  },
}
