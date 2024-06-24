# Components

Entities are designed to be used with Components, which are reusable bits oc foce. Such is the Godot way.  
Components aren't particularly special; they simply have a few functions for workign with the entities.

## Functionality

- Allows you to specify dependencies, which if it doesn't have, shows up as a warning in the editor
- Virtual functions for generation, spawning, despawning
- Saving, loading
- Gathering debug information
- Printing to console with entity's name, etc.

## Making your own

Simply inherit the SKEntityComponent class, and have at it! Just make sure it renames itself to its class name:  
the entity's `get_component()` method looks for names, since GDScript has no proper generics.  
Also note that you have an easy way to grab the parent entity: `parent_entity`. 
If you would like to provide a custom preview scene for manipulating your entity in the editor with SKWorldEntites,
implement a `get_world_entity_preview() -> Node` method that returns a scene you'd like to appear in the editor.

## Built-in components

A number of built-in components are offered for your convenience. More in-depth usage of these can be found in their in-engine documentation.

- Attributes: Covers attributes like Strength, Perception, Endurance, etc.
- Chest: Creates a refilling chest system. Expects a loot table.
- Covens: Integrates with Skelerealms Factions system.
- Damageable: Allows this entity to be damaged.
- Effects: Allows this entity to be subject to the status effects system.
- Equipment: This entity can equip items from an inventory into special equipment slots.
- GOAP: Puts the entity under control of the built-in GOAP system. GOAP Actions come as child nodes.
- Interactive: Allows the player (and others) to interact with this entity.
- Inventory: Gives the entity an inventory, along with management tools. Can use a Loot Table to generate an inventory. Also keeps track of currency.
- Item: This entity is now an item, and can be moved from inventory to inventory. Item Components come as child nodes.
- Marker: This entity can be used as waypoints, or whatever else you need. (I use them as destinations to teleport to in the console.)
- Navigator: Can calculate paths in the granular navigation system.
- NPC: This entity is now an NPC, and has many things it can do as a consequence. AI Modules come as child nodes.
- Player: This entity is a Player.
- Puppet Spawner: Spawns scenes into the game world as "puppets" that are linked to the entity. Used by Items and NPCs to give form to their being.
- Script: Deprecated.
- Shop: This entity can now barter in the barter system. Needs an overhaul.
- Skills: Keeps track of an entity's Skills - One-handed, block, archery, etc.
- Spell Target: Deprecated. Use EffectsComponent instead.
- Teleport: This entity can be teleported.
- View Direction: Keeps track of an entites viewing direction, for stealth mechanics and other such things.
- Vitals: Keeps track of health, stamina, magica, etc.
