# Vire TD

> Hex-grid roguelike tower defense where tower placement determines enemy pathing. Dynamic, ever-changing runs.

![Vire-Game](https://github.com/user-attachments/assets/03bf8d02-9c1b-41c8-bb94-4f77c6779ddb)

---

## Concept

Most tower defense games give you a fixed path and ask you to line it with towers. Vire flips that. Your base sits at the center of a hex grid; enemy nests spawn on the outer edges. There are no predefined routes — **the paths enemies take are determined entirely by where you place your towers.**

Every placement decision is spatial and strategic. Also, the roguelike layer means no two runs play the same way, and the pressure to adapt never stops. The game will be meant to move with your pace, but challenge you all the same. Newbies and veterans to the game alike will struggle, but an understanding of how to work with the pacing is the mechanic that I want the player to master.

---

## Current State

The core systems are built and functional. What exists right now:

- **Hex grid & pathfinding** — enemies dynamically calculate routes based on the current state of the board
- **Tower placement** — place and remove towers freely; the path updates in real time
- **Wave system** — enemy spawning and wave progression from outer nests
- **Base defense** — health, damage tracking, and loss conditions

What's not here yet: content. The engine is running; it's waiting to be filled out.

---

## Roadmap

- [ ] Roguelike layer — run structure, upgrades, and meta-progression
- [ ] Expanded tower roster with distinct mechanics
- [ ] Expanded enemy types with varied behaviors and stats
- [ ] Visual polish and juice
- [ ] Sound design

---

## Notes

This is a public mirror of the scripts and resources from a private working repository. Assets and scenes are excluded. The project is in active development.

**Built with:** Godot
