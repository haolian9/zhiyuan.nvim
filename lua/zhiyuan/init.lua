local M = {}

local api = vim.api
local uv = vim.loop

local lib = require("libzhiyuan")

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

---@enum urgency
local urgency_codes = {
  low = 0,
  normal = 1,
  critical = 2,
}

---@param summary string
---@param body string|nil
---@param icon string|nil @default nvim icon if any
---@param urgency string|nil @default "normal"
---@param timeout number|nil @default 1000 ms
function M.notify(summary, body, icon, urgency, timeout)
  assert(summary ~= nil)
  body = body or ""
  icon = icon or nvim_icon
  local urgency_code = urgency_codes[urgency or "normal"]
  assert(urgency_code ~= nil)
  timeout = timeout or 1000
  assert(0 <= timeout)

  ---@diagnostic disable: undefined-field
  return lib.notify(summary, body, icon, urgency_code, timeout)
end

return M
