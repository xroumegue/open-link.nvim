local expand = require("open-link.expand")

local function is_http_link(link)
  return vim.startswith(link, "http://") or vim.startswith(link, "https://")
end

---@param command string
---@param link string
local function exec(command, link)
  vim.fn.jobstart({ command, link }, {
    on_exit = function(_, exitcode, _)
      if exitcode == 0 then
        vim.notify("Link opened.")
      else
        vim.notify(
          'Error opening link with "' .. command .. " " .. link .. '"',
          vim.log.levels.ERROR
        )
      end
    end,
  })
end

---@param link string
local function browse(link)
  if vim.env.SSH_TTY ~= nil then
    vim.notify("Link copied to clipboard.")
    require("osc52").copy()
  elseif vim.fn.has("wsl") == 1 then
    exec("explorer.exe", link)
  elseif vim.fn.has("macunix") == 1 then
    exec("open", link)
  else
    exec("xdg-open", link)
  end
end

---@param link? string
local function open(link)
  if link == nil then
    link = vim.fn.expand("<cfile>")
  end

  link = expand(link)

  if not is_http_link(link) then
    link = "http://" .. link
  end

  browse(link)
end

return open
