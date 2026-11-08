# POLARIS — Cold War [BIPODS]

A script for **Cold War** (place `13687899540`) — 80-player NATO vs PACT battles with real ballistics.

Latest build: **Cold War [BIPODS]** (placeVersion `8570`). Everything here was re-verified against that build live — the fire path is unchanged (`ClientFire.sLnpiWe6Dt(tool, ...)` and turret calls by weapon name), so the silent mechanisms still hold, and the new bipod system has its own integrations (BIPOD flags, a ready ring, game-gated auto-deploy).

Everything in here was measured against the live game before it shipped. The
silent shot is solved with the game's own trajectory maths, the mounted path
was read out of `TurretFireController`, the helmet flag uses the same
`Headwear` rules the game applies, and the x-ray draws the game's own
penetration packets. Nothing is a guess.

## Load it

Paste this into your executor while Cold War is running:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fervidos/ColdWar/refs/heads/main/loader.lua"))()
```

The loader downloads the current packed builds, saves the panel into the
executor workspace and runs the script.

- **RightShift** shows / hides the panel. **F1** is the panic key.
- Every load opens with the **POLARIS cinematic startup** — a starfield intro
  whose loader tracks real initialisation (game load, camera, character).
  Click / tap to skip; it fades out into the panel when ready.
- First run asks once whether you are on PC or phone.
- Settings save automatically (`polaris-*.txt` in the executor workspace)
  and are restored on the next join.

---

## Features

### 🎯 Aim — where the round lands, not where the camera looks

**Silent aim — a genuinely bent shot.** Your own shot is redirected inside
the game's volley *before* it is encoded, so the server's copy and your
client's copy of the round are the same real trajectory — the camera never
moves. Aim is solved for bullet drop and drag with the game's published
`Trajectory` maths, and the arc is walked with the bullet's own raycast
params: the shot is only redirected when it actually reaches a limb.

**Hit chance, FOV in degrees, hit-part picker.** Only a chosen percentage of
rounds bend; the rest fly exactly where you aimed with the game's own spread.
The FOV default sits inside the range that was proven against live server
limb health, and the slider says so.

**Mounted silent aim.** The same solver for vehicle guns, driven from the
turret's own fire params and gated by the game's `TurretRig` / `Gunner`
contract — it only runs while you are the verified gunner. Has its own hit
chance (default 75%) so a mounted gun that never misses doesn't look like
one. Explosive launchers are left alone.

**Bipod support (Cold War [BIPODS], placeVersion 8570).** The update adds a
gun-mount system (`BipodController` / `BipodRig` / `MountSolver` + the
`Remotes.Bipod` channel): the gun anchors to the ground, aims through the
solver, and scoped Settled stance drops the ADS spread. POLARIS spans the gap —
`BIPOD`-flagged enemies are the ones currently planted (they carry a
replicated `BipodAnchor` / `BipodMounted` pair, so they read as a mount, not
a stance), and an optional auto-deploy calls the game's own `toggle()` — which the game itself gates on
that same availability scan, so the plant can never happen where the game
would not have planted it. The shot path is untouched by the update, so silent
aim bends bipod-mounted shots exactly like standing ones.

**Camera aimbot with humanisation.** Reaction delay, wind-up ramp and a
speed ceiling — it reads like a player flicking, not a snap. Sticky target,
visibility-only option, and true drop/lead prediction so the camera points
where the bullet will be, not where the target is.

### 🧠 Intel — the part no other panel has

**Radio interceptor.** Enemy voice lines are turned into subtitles at the
bottom of your screen, exactly the way each player's radio/voice distance
would distort them. `Status/Reloading` and `Status/OutOfAmmo` calls set a
**RELOADING** flag on that player — the game's own words telling you they're
dry. (Reads the game's `Callouts` signal; nothing is sent.)

**Helmet sense.** Marks anyone still wearing a helmet — and a helmeted head
is where headshot claims go to die, because the hat's handle eats the
bullet. The moment the game knocks the helmet off (it really does, on head
impacts) a **KNOCKED** flash tells you the head is now bare.

**HitCam armour x-ray.** When a vehicle takes a hit, the game ships an
encoded penetration packet — impact point, penetrator / jet / fragment lines,
crew, module and ammo-detonation events. POLARIS decodes the same packet the
in-game killcam uses and draws it in 3D: real round paths through the hull,
outcome labels like `AMMO DETONATION + MODULE`, colour-coded by what was hit.

**Threat monitor.** Counts how many enemies can actually see you, how many
are currently facing you, and where the nearest one is. Includes line-of-sight
unless you turn it off.

### 👁 ESP — everything, at a glance

- Boxes with outline, names, class (Sniper / AT / Medic …), distance and weapon
- **Per-limb health**: a health bar built from all six limbs, plus exact head
  and torso numbers (a head at 3 dies to the next hit)
- Status flags: `DOWNED`, `SPAWN`, `DISGUISED`, `VEHICLE`, plus the intel
  flags `HELMET`, `KNOCKED`, `RELOADING`
- Skeleton bones, tracers, head dots
- Visibility handling: *dim hidden* targets or *hide* them completely — your
  call, per the situation
- Teammates in blue, vehicle labels (manned by crew team, or empty)

### 📡 Battle radar — your half of the map on one dial

Rotating radar with enemy contacts, teammates, vehicles, live turret firing
directions, and capture objectives with owner and progress. Shot pings follow
enemy gunfire across the map and damage pings mark where you've been hit.
The footer shows the frontline both teams are pushing.

### 💥 World & utility

- No fog / fullbright / no suppression blur — visual only, your screen only
- **Launcher impact predictor**: while a supported launcher is equipped
  (`M203` / `M16A2+M203` / `GP-25` / `AK-74+GP-25` / `RPG-7` / `RPG-7V` /
  `M72A3` / `AT4` / `Carl Gustav` / `LAW` / `Chinalake` / `APILAS` / `RPG-18` /
  `RPG-76`), draws the real blast ring, crosshair, flight distance and arming
  state (display-only — it never changes where the rocket goes)
- Panic key (default `F1`) drops aim and silent instantly

### 🖥 The panel itself

POLARIS v4 is a self-contained tabbed panel: **HOME · ESP · AIM · SILENT ·
MOUNTED · WORLD · RADAR · INTEL · INFO · SETTINGS**. Live status strip with a
master switch and three counters, per-toggle save, one-click reset, and a
remembered PC / phone layout. It fetches nothing, links nothing, and every
control is drawn by the panel file itself.

---

## Safety by design

The game carries a hidden anticheat that watches for resized hitboxes, body
movers, noclip, anchored flips and the images in your GUI. This script
changes none of those things:

- the ESP is drawn **outside** the game with Drawing objects — not one part is
  resized, and nothing is added to any character
- the silent shot never claims a hit it didn't physically make — it bends a
  real round and lets the normal ballistics decide
- the panel lives outside the DataModel where the executor allows it, and the
  detector itself is left running untouched
- every default (FOV, hit chance) is chosen so the *behaviour* stays inside
  what normal play produces

## Files

| file | what it is |
| --- | --- |
| `loader.lua` | the one-liner you paste — fetches and runs the packaged builds |
| `build/coldwar.lua` | packed build of the script |
| `build/ui-template.lua` | packed build of the POLARIS panel |

Single-file use also works: the coldwar build falls back to fetching the
panel itself when the loader was not used.

## Builds

Everything under `build/` is a **packed build** — strings encrypted, comments
and whitespace stripped, the whole file stream-coded and checksum-guarded.
The readable sources are kept private and are not published here. The loader
refuses anything that is not a POLARIS build, so a stale mirror can never
come back.

## Updating

Change the sources locally, run `python tools/obfuscate.py`, then commit and
push the regenerated files under `build/`. The next loader run picks them up —
the panel is fetched cache-busted and written to disk on every run.
