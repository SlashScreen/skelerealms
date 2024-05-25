# Entities and Components

## Entities 

Anything that needs to have cross-scene persistence must be an *Entity*. These are roughly equivalent to CE's *Actors*. An *Entity* is defined as a tree of nodes descending from an `SKEntity` node. During runtime, these entities will live underneath the `SKEntityManager`, which keeps track of what entity goes in what scene, among other things.

## Components

*Entites* are largely made up of *Components*. These are nodes that derive from `SKEntityComponent`, special nodes that have built-in management functions. 
