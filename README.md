# Knockout with Ranged Weapons

A [Ninja](https://github.com/szapp/Ninja) patch for **Gothic II: Night of the Raven** (report version 2.6).

Lethal shots of the player with a bow or crossbow knock humans out instead of killing them, just like melee
combat does. Monsters, orcs and NPCs that cannot be knocked out in melee either (e.g. bandits) still die.

## How it works

The engine decides between death and knockout in `oCNpc::OnDamage_Condition()` after the damage was applied.
A knockout is only allowed for blunt or edge damage, so projectiles (point damage) always kill.

The patch hooks the start of that function. If the player's shot brought a human to 0 HP and the mod's
`C_DropUnconscious` script allows a knockout, it restores 1 HP. The engine then knocks the NPC out as usual.

## Requirements

- Gothic II: NotR 2.6 (the Steam version)
- [Ninja 4](https://github.com/szapp/Ninja) or higher
- [Toolkit](https://github.com/szapp/Toolkit) (Ikarus and LeGo for Ninja patches)

## Installation

Copy `KnockoutRanged.vdf` to `Gothic II\Data\`. Type `Ninja` in the in-game console to check that the patch is loaded.
To uninstall, delete the file. The patch stores nothing in save games.

## Building

```bash
go install github.com/kirides/vdfsbuilder/cmd/vdfsbuilder@latest
vdfsbuilder KnockoutRanged.vm
```

## License

[MIT](LICENSE)
