# Migrating from 0.5 to 0.6

This will not be easy. Sorry in advance.

## Instance data

This will be spotty at best, but a button will appear above `InstanceData`-derived classes that, when pressed, will create a roughly-equivalent Entity, and save it under the same directory. AI-related things and Loot boxes will not be conserved.

## GOAP

Luckily, this is easy. Simply change your existing GOAPBehaviors to GOAPActions. Instead of being a property, however, prerequisites and effects have moved into functions to override.

## Loot tables, schedules

You will have to remake these from scratch. Sorry.
