local CATALOG_URL =
"https://raw.githubusercontent.com/H3X-cpm/my-gg-library-cpm/main/catalog.lua"

local function stop(message)
  gg.alert(message)
  os.exit()
end

local function download_function(url)
  local response = gg.makeRequest(url)

  if not response or response.code ~= 200 or not response.content then
    return nil, "Could not download:
" .. url
  end

  local fn, error_message = load(response.content, url, "t")

  if not fn then
    return nil, "Lua error:
" .. tostring(error_message)
  end

  return fn
end

local catalogue_loader, error_message =
  download_function(CATALOG_URL)

if not catalogue_loader then
  stop(error_message)
end

local ok, catalogue = pcall(catalogue_loader)

if not ok or type(catalogue) ~= "table" then
  stop("The catalogue is invalid.")
end

local menu = {}

for i, item in ipairs(catalogue) do
  menu[i] = item.title .. " v" .. tostring(item.version or "?")
end

if #menu == 0 then
  stop("No creator-approved scripts are available.")
end

local selected = gg.choice(menu, nil, "My Script Library")

if not selected then
  os.exit()
end

local chosen = catalogue[selected]

if type(chosen) ~= "table"
   or type(chosen.url) ~= "string" then
  stop("That script is not approved.")
end

local script_loader, script_error =
  download_function(chosen.url)

if not script_loader then
  stop(script_error)
end

local script_ok, script = pcall(script_loader)

if not script_ok or type(script) ~= "function" then
  stop("This file is not an approved library script.")
end

local run_ok, run_error = pcall(script)

if not run_ok then
  stop("Script error:
" .. tostring(run_error))
end