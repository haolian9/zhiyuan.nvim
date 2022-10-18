local M = {}

local ffi = require("ffi")
local api = vim.api
local uv = vim.loop

local root = (function()
  -- thanks to bfredl for this solution: https://github.com/neovim/neovim/issues/20340#issuecomment-1257142131
  local source = debug.getinfo(1, "S").source
  assert(vim.startswith(source, "@") and vim.endswith(source, "init.lua"), "failed to resolve the root dir of zhiyuan.nvim")
  return vim.fn.fnamemodify(string.sub(source, 2), ":h:h:h")
end)()

local nvim_icon = (function()
  local runtime = os.getenv("VIMRUNTIME")
  if runtime == nil then return "" end
  if not vim.endswith(runtime, "/share/nvim/runtime") then return "" end
  local icon = string.format("%s/%s", string.sub(runtime, 1, #runtime - #"/nvim/runtime"), "icons/hicolor/128x128/apps/nvim.png")
  local stat, errmsg, err = uv.fs_stat(icon)
  if stat ~= nil then return icon end
  if err == "ENOENT" then return "" end
  api.nvim_err_writeln(errmsg)
  return ""
end)()

ffi.cdef([[
  int zhiyuan(const char *title, const char *msg, const char *icon, unsigned int urgency, int timeout);
]])
_ = ffi.load(string.format("%s/%s", root, "zig-out/lib/libzhiyuan.so"), true)

-- the c namespace
local C = ffi.C

---@enum urgency
M.urgency = {
  low = 0,
  normal = 1,
  critical = 2,
}

---@param summary string
---@param body string|nil
---@param icon string|nil
---@param urgency number|nil @default nvim icon if any
---@param timeout number|nil @default 1000ms
function M.notify(summary, body, icon, urgency, timeout)
  assert(summary ~= nil)
  body = body or ""
  icon = icon or nvim_icon
  urgency = M.urgency.normal
  timeout = timeout or 1000

  ---@diagnostic disable: undefined-field
  return C.zhiyuan(summary, body, icon, urgency, timeout) == 1
end

return M
