# POLARIS — Cold War

Panel + gameplay script for **Cold War** (place `13687899540`).

## Load it

Paste this into your executor while Cold War is running:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fervidos/ColdWar/refs/heads/main/loader.lua"))()
```

The loader downloads the current packed builds (`build/ui-template.lua` +
`build/coldwar.lua`) from this repo, saves the panel into the executor
workspace and runs the script.

- **RightShift** shows / hides the panel.
- First run asks once whether you are on PC or phone.
- Settings save automatically to your executor workspace (`polaris-*.txt`)
  and are restored on the next join.
- The panel is read from disk first, so the loader keeps it in sync on every
  run; a cache-buster defeats the raw.githubusercontent CDN window.

## Files

| file | what it is |
| --- | --- |
| `loader.lua` | the one-liner you paste — fetches and runs the packaged builds |
| `build/coldwar.lua` | packed build of the script (ESP, aim, silent aim, mounted silent aim, radar, world, intel) |
| `build/ui-template.lua` | packed build of the POLARIS panel — self-contained UI, no downloads, no links |

Single-file use also works: the coldwar build falls back to fetching the panel
itself when the loader was not used.

## Builds

Everything under `build/` is a **packed build**. The readable sources are kept
private and are not published to this repository:

- strings are encrypted and decoded at run time,
- whitespace and comments are stripped,
- the whole file is stream-coded, checksum-guarded and re-encoded.

The loader refuses to run a `coldwar.lua` that does not carry the POLARIS
markers, so a stale mirror can never come back. Rebuilding is done locally with
`python tools/obfuscate.py`, which regenerates both files under `build/`.

## Panel

The panel is fully local: no changelog fetches, no bug-report form, no Discord
link, no analytics. Every control is drawn by the packed panel build.

Call surface (unchanged from older panels):

```lua
local UI  = loadstring(readfile("ui-template.lua"))()
local win = UI.Window({ title = "COLD WAR", subtitle = "POLARIS" })
local page = win:Page("ESP", UI.icon.eye)
local card = page:Card("DRAW", 1)
card:Toggle("ESP", CONFIG.esp, function(v) CONFIG.esp = v end, "hint")
win:SetStat(1, "42", "drawn")
```

`UI.Window`, `win:Page/Refresh/SetStatus/SetStat/SetMaster/OnMaster/Destroy`,
`page:Card`, `card:Toggle/Stepper/Slider/Dropdown/Button/Input/Label/Readout/
Colour`, `UI.config`, `UI.sweep` and every `UI.theme.*` / `UI.icon.*` /
`UI.font.*` key are supported.

## Updating

Change the sources locally, run `python tools/obfuscate.py`, then commit and
push the regenerated files under `build/`. The next loader run picks them up —
the panel is fetched cache-busted and written to disk on every run, and the
loader refuses anything that is not a POLARIS build.
