--!nocheck
-- loader.lua  --  the POLARIS one-line loader
--
-- Paste this into your executor while Cold War is running:
--
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/fervidos/ColdWar/refs/heads/main/loader.lua"))()
--
-- What it does, in order:
--   1. downloads the packaged ui-template build from this repo (cache-busted)
--      and writes it into the executor workspace as ui-template.lua, so
--      coldwar.lua always runs the CURRENT panel from disk;
--   2. downloads the packaged coldwar build, checks that it really is the
--      POLARIS build, and runs it.
--
-- If the executor has no file API the loader still continues: coldwar.lua
-- carries its own remote fallback for the panel. Everything is pcall'd, so a
-- dead network produces one clear error line, not a traceback.

local BASE = "https://raw.githubusercontent.com/fervidos/ColdWar/refs/heads/main/"
local TEMPLATE_URL = "build/ui-template.lua"
local TEMPLATE_FILE = "ui-template.lua"
local MAIN_URL = "build/coldwar.lua"

local function say(msg)
	print("[polaris] " .. tostring(msg))
end

-- Every executor spells HTTP differently enough that this has to try in
-- order; the first one that returns a non-empty body wins. The ?t= builder
-- keeps raw.githubusercontent from handing back a CDN copy of an older push.
local function fetch(name)
	local url = BASE .. name .. "?t=" .. tostring(os.time())
	local ok, body = pcall(function() return game:HttpGet(url, true) end)
	if ok and type(body) == "string" and #body > 0 then return body end
	if type(httpget) == "function" then
		local ok2, body2 = pcall(httpget, url)
		if ok2 and type(body2) == "string" and #body2 > 0 then return body2 end
	end
	local request = (syn and syn.request) or (http and http.request) or http_request or request
	if request then
		local ok3, res = pcall(request, {
			Url = url, Method = "GET",
			Headers = { ["User-Agent"] = "Polaris" },
		})
		if ok3 and res and type(res.Body) == "string" and #res.Body > 0 then return res.Body end
	end
	return nil
end

------------------------------------------------------------------ the panel
local template = fetch(TEMPLATE_URL)
if template and template:find("POLARIS", 1, true) and template:find("UI.Window", 1, true) then
	if type(writefile) == "function" then
		local wrote = pcall(writefile, TEMPLATE_FILE, template)
		if wrote then
			say("panel saved to " .. TEMPLATE_FILE .. " (" .. #template .. " bytes)")
		else
			say("panel downloaded, but this executor could not save it")
		end
	else
		say("panel downloaded (no writefile on this executor)")
	end
else
	-- Not fatal: coldwar.lua fetches the panel itself when disk has nothing.
	say("panel download failed - coldwar.lua will retry it on its own")
end

------------------------------------------------------------------ the script
local main = fetch(MAIN_URL)
if not main then
	error("[polaris] " .. MAIN_URL .. " could not be downloaded from " .. BASE, 0)
end
-- Sanity check before running anything: a 404 page or a stale file must never
-- be executed as a script. These two markers exist in every POLARIS build.
if not (main:find("__CWAR", 1, true) and main:find("ui-template", 1, true)) then
	error("[polaris] " .. MAIN_URL .. " downloaded but does not look like the POLARIS build - refusing to run it", 0)
end
local chunk, compileErr = loadstring(main, "coldwar")
if not chunk then
	error("[polaris] " .. MAIN_URL .. " did not compile - " .. tostring(compileErr), 0)
end
local ok, err = pcall(chunk)
if not ok then
	error("[polaris] " .. MAIN_URL .. " failed to run - " .. tostring(err), 0)
end
say("loaded - RightShift for the panel")
