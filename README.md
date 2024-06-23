# Skelerelams 

Welcome to Skelerealms, the framework for Bethesda-style Open World RPGs (Like Skyrim, Fallout New Vegas, etc.).  
This addon aims to offer a solution to the most challenging technical challenges faced while engineering games like this. Gameplay is, however, not included.  
For those familiar with Creation Engine's inner workings, Skelerealms seeks to primarily cover Actors, Cells, AI Packages, and Factions.  
Skelerealms is designed in such a way where you can ignore or replace most of the working components, and allow easy integration into your own gameplay systems.

## What does it have?

- Inter-scene persistence of important objects
- Inter-scene navigation
- A basic framework for skills and attributes
- Loot tables
- Inventory system
- Equipment system
- NPC AI
    - Behavious
    - GOAP AI System
    - Basic perception
    - Schedules
    - Patrol paths
- Tools to assist development
- Composable design
    - Components for entities
    - Components for items
- Dungeon puzzle elements
- Factions
- Spells/Status Effects
- Crime
- Bartering
- Spawn zones
- Doors

## What does it *not* have? 

- Gameplay
- Terrain
- LOD system, chunks
- UI
- Dialogue
- Quests (Ironically)
- Combat

## How do I get started? 

Visit the wiki for more details.

## What's the project status?

The project is active. I am using this to develop my own game, and will occasionally push changes I make upstream.  
Please note that the project is in an Alpha state, which means breaking changes can and will happen often. Plan around this. I plan to have feature and API stability once 1.0 is reached.

## What's in store?

- 0.6 (In Development)
    - Redesigning the way entities are stored.
    - Adding more tools.
    - Writing more thorough documentation.
    - Integrating NetworkGD.
- 0.7
    - Redesigning the save game system.
