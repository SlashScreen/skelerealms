# Navigation

TODO

This is for cross-scene navigation. I might rework the way you do this soon but basically you use the network tool. You can find the repo [here](https://github.com/SlashScreen/godot-network-graph) and look at the wiki for how to use it, but I'm about to merge it into Skelerealms, I think, since having external dependencies creates complications. Anyway, save the network for a world into the networks folder in the project settings, and the system will pick it up into the pathfinding later. Cross-scene navigation is done using the `NavigatorComponent`, although I'm not sure it works right now. 
