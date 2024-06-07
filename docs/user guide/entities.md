# Entities

Any scene with SKEntity as the root is considered an Entity. Entities are able to persist between scenes, so use these for everything you want
to stay put when unloaded: NPCs, Items, etc. Entities by themselves do very little - the first layer of children should be made up of SKEntityComponents, 
reusable bits of code that inform the behavior of an Entity; for example, keeping track of an inventory.

## Functionality

Entities do have some functionality, though; they keep track of the following:

- Position and rotation of the entity (Note that SKEntity is *not* a Node3D; Making it one does some funky stuff with puppets.)
- The world the entity is in 
- Whether the entity should be in the scene or not
- Form ID (used for determining what sort of thing non-unique entities are)
- Whether this entity is unique.

It provides some hooks for:

- Spawning, despawning
- Actions called from dialogue
- Generation
- Getting a preview mesh (Components can provide a preview mesh for you to see when placing them in the editor)

As well as utility functions for:

- Saving
- Loading
- Gathering debug information (used for debug consoles and the like)
- Managing components

## Concepts

The life cycle of an entity goes as follows:
```
Generation -> Spawning <-> Despawning -> Destruction
```

**Spawning** happens every time an entity appears in a scene. This is used for spawning anything 
associated with the entity that the player interacts with (referred to as puppets).  

**Generation** is when the entity appears for the first time in a game. Not a game *session*, but a game. This is distinct from spawning
in that spawning occurs every time an entity appears in a game *session*. Further appearances of the entity will be aided by the save game system.
Generation should be used for filling inventories for the first time.  

**Destruction** means the entity will no longer exist in the game, ever. This stage is a work-in-progress, and will probably come in 0.7.

**Uniqueness** simply means that there will only be one instance of this entity that exists in the game; usually used for named NPC and unique items.
Internally, non-unique entities will be given a randomly-generated RefID upon generation. Non-unique entities should probably be given a FormID.  

## Creating an entity

Simply create a new scene with an SKEntity as the root, and name it with a RefID if it's unique. The first layer of the tree 
under the SKEntity should all be made of SKEntityComponent-derived nodes. Beyond that, that's up to whatever the components expect to be beneath them.  
Then, save the entity as a scene file (I prefer `.res`) in the entities path under the `skelerealms/entities_path` project setting; `res://entities` by default.
They can be in a subdirectory for organization.  
In the very likely chance that you have many entities with the same general shape, like NPCs, you can have an "archetype" scene that you can inherit entities from, using
the editor's "ingerit scene" functionality. This is handy for saving legwork, as well as changing large swaths of entities at once. Some archetypes are provided in the 
Skelerealms folder.  
To place individual entities in the world, you can create an SKWorldEntity, and place in an Entity in the inspector. Depending on the entity, you will get a preview. 
Manipulate the World Entity to your linkng, then hit "Sync position and world" in the inspector. This will automatically edit the entity to set its position and world  
so it spawns where you placed it in the world.
