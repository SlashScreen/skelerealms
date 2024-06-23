# Tools

Skelerealms offers a few tools to help with your development.

## Node Bundles

If you want to compose a set of AI Modules, Loot table items, etc. the `NodeBundle` class aims to help with that. All it does is take all of its children and reparent them to be siblings of itself, and then removes itself afterwards. Since some systems rely on a tree's structure to determine functionality, this is handy for having a scene you can drag in while making an entity, helping for composability. Simply make a scene with a NodeBundle as a root and all your items below it, and it will flatten out during runtime.
