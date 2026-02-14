1. Open a Python file and run :LspInfo (or :lua vim.print(vim.lsp.get_clients())) to see if basedpyright is attached atall.
2. Check :LspLog for errors.
3. Verify Mason installed it: ls ~/.local/share/nvim/mason/bin/basedpyright\*
4. Check Neovim version on both machines: :version — the vim.lsp.config/vim.lsp.enable API is relatively new (0.11+). If Arch has an older version, this entire config won't work.

My top suspicion: Different Neovim versions. The vim.lsp.config() / vim.lsp.enable() API requires Neovim 0.11+. If your
Arch install has an older Neovim, none of your LSP servers would start and you'd get no errors — just silence. Can you
check nvim --version on both machines?
