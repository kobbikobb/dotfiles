-- ys = surround text with ... w... "
-- ds ... " ... delete around 
-- cs ... " ... change around
return {
  "kylechui/nvim-surround",
  event = { "BufReadPre", "BufNewFile" },
  version = "*",
  config = true
}

