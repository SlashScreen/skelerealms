class_name GOAPComponent
extends EntityComponent
## Planner for [GOAPAction]s that creates action sequences to complete a set of [Objective]s.


var agent_state:Dictionary = {}
var objectives:Array[Objective] = []
var action_queue:Array[GOAPAction] = []


## Creates a plan to satisfy a set of goals from all child [GOAPAction]s.
func plan(actions:Array[GOAPAction], goal:Dictionary, world_states:Dictionary) -> Array[GOAPAction]:
	var action_pool:Array[GOAPAction] = actions.filter(func(a:GOAPAction): return a.is_achievable()) # get all of the actions currently achievable.
	
	var leaves:Array[PlannerNode] # create an array keeping track of all of the possible nodes that could make up our path.
	var start = PlannerNode.build(null, world_states, null, 0) # build the starting node.
	var success = build_graph(start, leaves, goal, action_pool) # try to find a path.
	
	if not success: # if we have not found a path, we have failed.
		print("No plan")
		return []
		
	leaves.sort_custom(func(a:PlannerNode,b:PlannerNode): return a.cost < b.cost ) #Sort to find valid node with least cost.
	var cheapest:PlannerNode = leaves[0] # the cheapest will be at the bottom.
	
	var new_plan:Array[GOAPAction] = [] # create the plan for the AI to use. This will be treated like a queue.
	# walk back up the parent chain that the selected node has kept (sorta like a linked list) and build a queue from that.
	var n = cheapest 
	while not n == null: # if it is null, we have reached the root node, since it will have no parents.
		if not n == null:
			new_plan.push_back(n.action)
		n = n.parent
	
	#new_plan.reverse() # may be necessary?
	return new_plan


## Recursive method to try to find all possible action chains that could satisfy the goal.
func build_graph(parent:PlannerNode, leaves:Array[PlannerNode], goal:Dictionary, action_pool:Array[GOAPAction]) -> bool:
	var found_path:bool = false
	
	# due to the recursive nature of this function, we will be building branching paths from all of the actions until a valid path is found.
	for action in action_pool:
		
		# if we can achieve this action,
		if action.is_achievable():
			# duplicate our working set of states.
			var current_state:Dictionary = parent.states.duplicate(true)
			
			# Continue to accumulate effects in state, for passing on to the next node.
			current_state.merge(action.effects, true) # overwrite to keep the state up to date.
				
			# create a new child planner node, which will have an accumulation of all the previous costs.
			# this will help us find the shortest path later.
			var next_node:PlannerNode = PlannerNode.build(parent, current_state, action, parent.cost + action.cost)
			
			if goal_achieved(goal, current_state):
				# if we have reached the state we are looking for, append the node to the leaves, and set found_path.
				leaves.append(next_node)
				found_path = true
			else:
				# if we have not reached the goal,
				# create a subset of the action pool that removes the current action.
				# this will prevent circular action chains.
				var subset:Array[GOAPAction] = action_pool.duplicate() # no deep copy, we don't want to clone the nodes.
				subset.erase(action)
				
				# then, recurse and find the next possible node.
				if build_graph(next_node, leaves, goal, subset):
					found_path = true
	
	return found_path


## Determine whether we have satisfied all goals in our state.
func goal_achieved(goal:Dictionary, current_state:Dictionary) -> bool:
	return current_state.has_all(goal.keys())


## An objective for the AI to try to solve for.
class Objective:
	## Goals to satisfy this objective.
	var goals:Dictionary
	## Whether to remove this goal after it is satisfied.
	var remove_after_satisfied:bool


## Internal node for planning a GOAP chain.
class PlannerNode:
	var parent:PlannerNode
	var action:GOAPAction
	var cost:float
	var states:Dictionary
	
	
	static func build(p:PlannerNode, s:Dictionary, a:GOAPAction, c:float) -> PlannerNode:
		var pn = PlannerNode.new()
		pn.parent = p
		pn.action = a
		pn.cost = c
		pn.states = s
		return pn
