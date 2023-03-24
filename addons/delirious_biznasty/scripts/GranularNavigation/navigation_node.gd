class_name NavNode
extends Node3D
## A single navigation node in the granular navigation system.


## The connections/edges this node has to other nodes. [br]
## The structure of this dictionary is: [br]
## [Codeblock]
## connected_node_id:NavNode, cost:float
## [/Codeblock]
var connections: Dictionary = {}
