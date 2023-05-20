# Skelerealms - An open world RPG framework for Godot 4

Skelerealms is a work-in-progress framework for creating open world RPGs, like The Elder Scrolls series.  
Skelerealms is made to be modular and extensible, and easy to hook into for actual gameplay.  
**This addon is still under construction- should you use it, be wary of bugs.** (if you do find bugs, please open an issue!)  
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

Working, tested :evergreen_tree:  
Probably working but untested :warning:  
In progress :construction:  
Sketched out :pencil2:  
Not started :hole:  

| Feature | Status |
|---------|--------:|
| Scene persistence | :evergreen_tree:
| GOAP AI | :evergreen_tree: |
| Schedules | :evergreen_tree: |
| Outside of scene AI navigation | :evergreen_tree: |
| World loading | :evergreen_tree: |
| Skills/Attributes | :evergreen_tree: |
| NPC Perception | :warning: |
| Spells and Spell effects | :evergreen_tree: |
| Audio events | :warning: |
| Factions | :evergreen_tree: |
| Crime | :evergreen_tree: |
| Editor tools | :construction: |
| Quest system | :evergreen_tree: |
| Save/Load system | :warning: |
| Items | :evergreen_tree: |
| NPCs | :warning: |
| Chests | :evergreen_tree: |
| Merchants | :evergreen_tree: |

## Planned Plugins

- A compatability layer with [Gloot](https://github.com/peter-kish/gloot) to work with the in-house inventory system
- A location-based asset streamer, allowing you to load in chunks of objects based on proximity to the player.

## Future Imporovements

- I'd like to rework the way inter-scene navigation is represented during runtime, because the current method is cumbersome and not anywhere close to memory-efficient. Packed arrays and lots of index maps world do well. However, I need something that works right now.
- I'd like to make much more advanced editor tools to make the experience very easy.
- Much more thorough tests.
