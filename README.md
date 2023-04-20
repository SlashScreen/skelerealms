# Skelerealms - An open world RPG framework for Godot 4

Skelerealms is a work-in-progress framework for creating open world RPGs, like The Elder Scrolls series.  
Skelerealms is made to be modular and extensible, and easy to hook into for actual gameplay.  
This addon is still under construction, and should probably not yet be used.  
It is part of a family of sister addons, some of which it depends on:  
- [Godot Network Graph](https://github.com/SlashScreen/godot-network-graph) - **Required**
- [JournalGD](https://github.com/SlashScreen/journalgd-godot) - **Required**
- [Bibliodot](https://github.com/SlashScreen/Bibliodot) - Not required, but intended to be used with this.

## What does it include?

- Extensible, modular design
- Persistence of objects/NPCs between scenes
- Items
- NPCs
- GOAP AI System
- NPC schedules
- NPC activity outside of scenes
- Quest system
- Save/Load system
- Spells system
- Skills/attributes system
- Editor tools
- Inventory management system
- Audio events (but not backend)
- Stealth mechanics
- Crime mechanics
- Factions

## What does it *not* include?

- Most game logic; it is not batteries-included
- Terrain system (I am working on a plugin for this, though)
- Open world streaming (plugin also)
- Console
- Audio backend
- Player controller
- HUD
- Dialogue system  

However, the system is designed to be able to hook into these. BYOB (Bring your own backend), though.

## Feature status

Working, stable :evergreen_tree:  
Probably working but untested :warning:  
In progress :construction:  
Sketched out :pencil2:  
Not started :hole:  

| Feature | Status |
|---------|--------:|
| Scene persistence | :evergreen_tree:
| GOAP AI | :warning: |
| Schedules | :warning: |
| Outside of scene AI navigation | :warning: |
| World loading | :evergreen_tree: |
| Skills/Attributes | :construction: |
| NPC Perception | :construction: |
| Spells and Spell effects | :warning: |
| Audio events | :warning: |
| Factions | :warning: |
| Crime | :construction: |
| Editor tools | :construction: |
| Quest system | :warning: |
| Save/Load system | :warning: |
| Items | :construction: |
| NPCs | :construction: |
| Chests | :construction: |
| Merchants | :construction: |
