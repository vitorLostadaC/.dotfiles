return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = { "%.next", "%.dist", "node_modules" },
      hidden = true,
      no_ignore = true,
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = true,
      },
      live_grep = {
        additional_args = function()
          return { "--hidden", "--no-ignore" }
        end,
      },
    },
  },
}
