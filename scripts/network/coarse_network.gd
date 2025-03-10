@tool
class_name CoarseNetwork
extends Resource
## A coarse navigation network for efficient pathfinding across game worlds.
## Uses packed arrays for memory efficiency and an octree for spatial queries.
## Supports portals for cross-world navigation.

const Octree = preload("res://addons/skelerealms/scripts/network/octree.gd")

## Spatial partitioning structure for efficient node lookup
## Maps 3D space to node indices
@export var octree: Octree

## Array of node positions in 3D space
## Uses packed format for memory efficiency
@export var positions := PackedVector3Array()

## Array of node connections encoded as pairs of indices
## Each pair represents a bidirectional connection between nodes
## Uses packed format for memory efficiency
@export var connections := PackedInt64Array()

## Array of portal node indices
## Portals are special nodes that connect different worlds
@export var portals := PackedInt64Array()

## Array of portal-to-portal connections within the same world
## Encoded as pairs of portal indices
@export var portal_connections := PackedInt64Array()

## Maps portal indices to their destinations in other worlds
## Key: Source portal index
## Value: Dictionary mapping destination world to destination portal index
@export var portal_destinations: Dictionary[int, Dictionary] = {}
