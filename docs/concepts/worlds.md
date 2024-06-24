# Worlds

*Worlds* are simply a way of expressing what scene an entity belongs to. This is roughly equivalent to CE's *Cells*.  

A scene becoming a World has two requirements:
- The root node (It should be a Node3D but it doesn't have to) has the name of the world
- The scene file is saved in the directory defined by `skelerealms/worlds_path` - by default, `res://worlds` (It can be in a subforlder for organization). The name of the file should exactly match the name of the root node.

That's it! 
