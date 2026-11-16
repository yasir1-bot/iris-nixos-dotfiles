-- Keep LazyVim plugin/spec structure while allowing Iris-generated overrides.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- Base colorscheme; Iris-generated highlights are applied on top by lua/theme/iris.lua.
      colorscheme = "tokyonight",
    },
  },
}
