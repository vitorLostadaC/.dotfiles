return {
  "eandrju/cellular-automaton.nvim",
  keys = {
    {
      "<leader>fml", -- The key sequence
      "<cmd>CellularAutomaton make_it_rain<CR>", -- The command to execute
      mode = "n", -- The mode in which this keymap is valid ("n" for normal mode)
      desc = "Trigger CellularAutomaton Make It Rain", -- Description (optional, useful for which-key integration)
    },
  },
}
