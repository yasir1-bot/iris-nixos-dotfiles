-- Autocmds: reapply Iris theme on focus/resume if generated file changed.
local function reload_iris()
  pcall(function()
    package.loaded["theme.iris"] = nil
    require("theme.iris")
  end)
end

vim.api.nvim_create_autocmd({ "FocusGained", "VimResume" }, {
  callback = reload_iris,
})

vim.api.nvim_create_user_command("IrisReload", reload_iris, { desc = "Reload Iris-generated Neovim colors" })
