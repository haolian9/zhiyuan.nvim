local M = {}

local ffi = require("ffi")

local root = (function()
  -- thanks to bfredl for this solution: https://github.com/neovim/neovim/issues/20340#issuecomment-1257142131
  local source = debug.getinfo(1, "S").source
  assert(vim.startswith(source, "@") and vim.endswith(source, "init.lua"), "failed to resolve the root dir of zhiyuan.nvim")
  return vim.fn.fnamemodify(string.sub(source, 2), ":h:h:h")
end)()

ffi.cdef([[
  int zhiyuan(const char *title, const char *msg, const char *icon, int timeout);
]])
_ = ffi.load(string.format("%s/%s", root, "zig-out/lib/libzhiyuan.so"), true)

-- the c namespace
local C = ffi.C

---@param timeout number @default 1000ms
---@param icon string|nil
function M.notify(title, msg, timeout, icon)
  assert(title ~= nil and msg ~= nil)
  icon = icon or ""
  timeout = timeout or 1000

  -- stylua: ignore
  ---@diagnostic disable: undefined-field
  local rv = C.zhiyuan(
    ffi.new("char[?]", #title, title),
    ffi.new("char[?]", #msg, msg),
    ffi.new("char[?]", #icon, icon),
    timeout
  )

  return rv == 1
end

return M
