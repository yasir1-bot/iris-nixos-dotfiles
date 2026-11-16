-- Loads Iris-generated colors from ~/.cache/iris/colors-nvim.lua (rendered from custom template)
-- and applies best-effort highlight overrides. Safe no-op if file is missing.

local M = {}

local function read_generated()
  local path = vim.fn.expand("~/.cache/iris/colors-nvim.lua")
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  local ok, colors = pcall(dofile, path)
  if not ok or type(colors) ~= "table" then
    return nil
  end
  return colors
end

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.apply()
  local c = read_generated()
  if not c then
    return false
  end

  -- Minimal, broadly compatible overrides (extend as needed).
  hi("Normal", { fg = c.fg, bg = "NONE" })
  hi("NormalFloat", { fg = c.fg, bg = c.surface })
  hi("FloatBorder", { fg = c.dim, bg = c.surface })
  hi("CursorLine", { bg = c.surface })
  hi("LineNr", { fg = c.dim })
  hi("CursorLineNr", { fg = c.accent, bold = true })
  hi("Visual", { bg = c.surface })
  hi("Search", { fg = c.bg, bg = c.yellow })
  hi("IncSearch", { fg = c.bg, bg = c.accent })
  hi("Comment", { fg = c.syntax_comment or c.dim, italic = true })
  hi("Keyword", { fg = c.syntax_keyword or c.accent })
  hi("String", { fg = c.syntax_string or c.green })
  hi("Function", { fg = c.syntax_func or c.blue })
  hi("Type", { fg = c.syntax_type or c.yellow })
  hi("Constant", { fg = c.syntax_const or c.magenta })
  hi("Identifier", { fg = c.fg })
  hi("Statement", { fg = c.syntax_keyword or c.accent })
  hi("DiagnosticError", { fg = c.red })
  hi("DiagnosticWarn", { fg = c.yellow })
  hi("DiagnosticInfo", { fg = c.blue })
  hi("DiagnosticHint", { fg = c.cyan })
  hi("Pmenu", { fg = c.fg, bg = c.surface })
  hi("PmenuSel", { fg = c.bg, bg = c.accent, bold = true })
  hi("StatusLine", { fg = c.fg, bg = c.surface })
  hi("WinSeparator", { fg = c.dim })

  return true
end

M.apply()
return M
