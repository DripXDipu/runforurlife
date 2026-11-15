# RUN FOR UR LIFE

> **SURVIVE. ESCAPE. TRUST NOTHING.**

A small top-down 2D horror-survival game built with **Godot 4.7**. You have exactly one hit point. Collect the herbs, unlock the door, and outlast the things hunting you.

---

## Gameplay

You play as a knight with **1 HP**: a single hit sends you to the Game Over screen. There is no attack button, so your only option is to run.

| Level | Goal | Threat |
|-------|------|--------|
| **Level 1: Herbs** | Find and collect **3 herbs** scattered randomly around the room. This unlocks the exit door. | A chasing enemy |
| **Level 2: Survival** | Stay alive for **90 seconds** while dodging obstacles in a long, wide arena. | Three chasing enemies |

Enemies spot you from a long way off, chase relentlessly, and attack on contact. Keep moving.

### Controls

| Action | Keys |
|--------|------|
| Move | `W` `A` `S` `D` or Arrow keys |
| Pause / resume | `Esc` |

The pause menu lets you resume, restart the level, or return to the main menu. The main menu has a settings panel with **Music** and **Sound Effects** volume sliders.

---

## Running the game

### Pre-built binaries (included in the project folder)

| Platform | File |
|----------|------|
| Windows | `Runforurlife.exe` (use `Runforurlife.console.exe` to see debug output) |
| Linux (x86_64) | `./Runforurlife.sh`, or run `Runforurlife.x86_64` directly |

Keep `Runforurlife.pck` in the same folder as the executable. The `.pck` is **not embedded**, and the game will not start without it.

On Linux you may need to mark the files executable first:

```bash
chmod +x Runforurlife.x86_64 Runforurlife.sh
./Runforurlife.sh
```

### From source

1. Install [Godot **4.7**](https://godotengine.org/download) (the standard build is fine).
2. Open Godot, click **Import**, and select `project.godot`.
3. Press **F5** to run. The main menu is the main scene.

The project uses the **Forward Plus** renderer, Jolt Physics, and Direct3D 12 on Windows. The window is 960×600 and scales with `canvas_items` stretching.

### Exporting

Two presets are set up in `export_presets.cfg`: **Windows Desktop** and **Linux** (both x86_64, PCK not embedded). Use *Project → Export*. The preset paths currently point to `../thefloorislying/`, so change them to wherever you want the builds to go.

---

## Project structure

```
runforurlife/
├── project.godot            # Project config, input map, autoloads
├── export_presets.cfg       # Windows + Linux export presets
├── Creepster-Regular.ttf    # UI font
├── pause_menu.gd            # Pause menu logic
│
├── game/                    # Scenes and level-specific scripts
│   ├── main_menu.tscn
│   ├── level1.tscn / level1.gd          # Herb-collecting level
│   ├── level2.tscn / level_2.gd         # Survival level
│   ├── level_manager.gd                 # Level 1: spawns herbs, tracks count, unlocks door
│   ├── level_manager_2.gd               # Level 2: 90-second survival timer
│   ├── floor_builder.gd                 # Level 1: paints room, walls, camera limits, spawns door
│   ├── ground2.gd                       # Level 2: paints arena, walls, random obstacles
│   ├── herb.gd / herb_1.tscn            # Collectible herb
│   ├── obstacle.tscn                    # Static obstacle (crate)
│   ├── scene_door_lite.tscn             # Exit door
│   ├── player.gd                        # Animations + death handling
│   ├── popup.gd / popup.tscn            # Timed on-screen messages
│   ├── pause_menu.tscn
│   ├── settings_panel.gd                # Volume sliders (built in code)
│   ├── gameover.tscn
│   ├── audio/                           # mainmenu.mp3, level1.mp3, level2.mp3
│   └── art/                             # Sprites, tiles, SpriteFrames resources
│
└── scripts/                 # Reusable systems
    ├── audio/audio_manager.gd           # Autoload: crossfading music, SFX pool, bus volumes
    ├── scene_flow/
    │   ├── scene_flow.gd                # Autoload: fade transitions + player spawn placement
    │   ├── door.gd                      # SceneDoor: locked/unlocked door that changes scenes
    │   └── spawn_point.gd               # Marker2D spawn points
    ├── controller/top_down_mover_lite.gd # 8-direction movement
    ├── combat/
    │   ├── health.gd                    # Health + damage flash + died signal
    │   ├── hurtbox.gd                   # Receives damage
    │   └── hitbox.gd                    # Deals damage (team-aware)
    ├── enemy_ai/brain.gd                # Enemy state machine
    ├── main_menu.gd
    └── gameover.gd
```

---

## How it works

**Autoloads.** Two singletons are registered in `project.godot`:
- `SceneFlow` handles fade-to-black scene changes and places the player at a spawn point after a transition.
- `AudioManager` crossfades looping music between two players and manages the `Music` and `SFX` audio buses (creating them if missing).

**Combat.** A small team-based system: a `Hitbox` damages any overlapping `Hurtbox` on a different team, which forwards the damage to a sibling `Health` node. When the player's `Health` emits `died`, the current level path is stored so **Retry** on the Game Over screen drops you back into the level you died in.

**Enemy AI.** `EnemyBrain` is a lightweight state machine (`idle → chase → attack`, plus `return`). It looks for any node in the `player` group, chases at `chase_speed` (140 by default, versus the player's 150), and swings its hitbox on a cooldown. Detection radius, attack radius, cooldown, and speeds are all exported and tweakable in the Inspector.

**Level generation.**
- Level 1 paints a 56×23-tile room, builds wall collision, clamps the camera, and spawns the door at the top of the room. Herbs are placed at random floor cells each run.
- Level 2 paints a 100×18-tile arena and scatters 8 obstacles with a minimum spacing, retrying up to 10× per obstacle.

**Tweaking the game.** Most values are exported properties:

| What | Where | Property |
|------|-------|----------|
| Herbs needed | `LevelManager` node in Level 1 | `herb_count` |
| Survival time | `LevelManager2` node in Level 2 | `survival_time` |
| Obstacle count | `Ground` node in Level 2 | `obstacle_count` |
| Player speed | `Player/Mover` | `speed` |
| Enemy speed / awareness | `enemy/EnemyBrainLite` | `chase_speed`, `detect_radius`, `attack_cooldown` |
| Player HP | `Player/HealthLite` | `max_health` |

---

## Known issues / TODO

- **Level 2 has no win state yet.** When the timer hits `00:00`, `win_level()` only prints "You survived!" to the console.
- The unlock popup says *"Press E to open"*, but the door actually opens when you walk into it.
- There is no `E` input action defined.
- Walking into the locked door only prints a hint to the console; nothing shows on screen.
- `SFX` bus and `play_sfx()` exist but no sound effects are wired up yet.
- The player has no way to fight back (by design, but you may want a weapon or power-up later).

---

## Credits

> Please fill in or correct these. I could not verify sources from the project files alone.

- **Engine:** [Godot Engine](https://godotengine.org/) (MIT)
- **Font:** Creepster by Sideshow, via Google Fonts (SIL Open Font License)
- **Sprites and tiles** (knight, goblin, skeleton, floors, walls, door, flask): the naming suggests the *0x72 DungeonTileset II* pack. Confirm the source and license.
- **Music** (`mainmenu.mp3`, `level1.mp3`, `level2.mp3`): *add composer / source / license*
- **Crate sprite and menu / game-over background images:** *add source / license*

## License

*Add a license (for example MIT) before publishing.*
# runforurlife
# runforurlife
