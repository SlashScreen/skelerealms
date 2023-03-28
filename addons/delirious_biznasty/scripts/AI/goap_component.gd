class_name GOAPComponent
extends EntityComponent
## Planner for [GOAPAction]s that creates action sequences to complete a set of [Objective]s.


var agent_state:Dictionary = {}
var objectives:Array[Objective] = []
var action_queue:Array[GOAPAction] = []

var _current_action:GOAPAction
var _current_objective:Objective
var _agent:NavigationAgent3D
var _invoked:bool
var _timer:Timer
var _rebuild_plan:bool


func _ready():
	# call the base class' ready because that's important
	super._ready()
	# add a timer if we have none
	if $Timer == null:
		add_child(Timer.new())
		_timer = ($Timer as Timer)


func _process(delta):
	# if we are not done with the current action
	if not _current_action == null and _current_action.running:
		if _agent.is_navigation_finished(): # if agent navigation is finished
			if not _invoked: # if we aren't actively waiting for an action to be completed
				if _current_action.target_reached(): # call the target reached callback
					_invoke_in_time(_complete_current_action.bind(), _current_action.duration)
					_invoked = true
				else:
					_rebuild_plan = true
		return
	
	# if we are set to rebuild our plan
	if _rebuild_plan:
		# Find the highest priority objective
		objectives.sort_custom(func(a:Objective, b:Objective): a.priority > b.priority)
		for o in objectives:
			action_queue = _plan(get_children()\
				.filter(func(x): return x is GOAPAction)\
				.map(func(x): return x as GOAPAction), o.goals, {}\
			)
			# if we made a plan, stop sorting through objectives
			if not action_queue.is_empty():
				_current_objective = o
				break
	
	# if we are done with the plan
	if not _rebuild_plan and action_queue.is_empty():
		# if we need to remove the objective, remove it
		if _current_objective.remove_after_satisfied:
			objectives.erase(_current_objective)
		# trigger plan rebuild next frame
		_rebuild_plan = true
	
	# if we are not done with our plan
	if not action_queue.is_empty():
		_current_action = action_queue.pop_front() # may need to pop back?
		_current_action.running = true
		# if pre perform fails, rebuild plan
		if not _current_action.pre_perform():
			_rebuild_plan
	


## Creates a plan to satisfy a set of goals from all child [GOAPAction]s.
func _plan(actions:Array[GOAPAction], goal:Dictionary, world_states:Dictionary) -> Array[GOAPAction]:
	var action_pool:Array[GOAPAction] = actions.filter(func(a:GOAPAction): return a.is_achievable()) # get all of the actions currently achievable.
	
	var leaves:Array[PlannerNode] # create an array keeping track of all of the possible nodes that could make up our path.
	var start = PlannerNode.build(null, world_states, null, 0) # build the starting node.
	var success = _build_graph(start, leaves, goal, action_pool) # try to find a path.
	
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
func _build_graph(parent:PlannerNode, leaves:Array[PlannerNode], goal:Dictionary, action_pool:Array[GOAPAction]) -> bool:
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
			
			if _goal_achieved(goal, current_state):
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
				if _build_graph(next_node, leaves, goal, subset):
					found_path = true
	
	return found_path


## Determine whether we have satisfied all goals in our state.
func _goal_achieved(goal:Dictionary, current_state:Dictionary) -> bool:
	return current_state.has_all(goal.keys())


## Invoke a callable in a set amount of time.
func _invoke_in_time(f:Callable, time:float):
	_timer.start(time)
	_timer.timeout.connect(func():
		# disconnect all events
		for c in _timer.timeout.get_connections():
			_timer.timeout.disconnect(c)
		# call function
		f.call()
	)


## Wrap up the running action.
func _complete_current_action():
	_current_action.running = false
	# if post perform fails, rebuild plan
	if not _current_action.post_perform():
		_rebuild_plan = true
	_invoked = false


## Add an objective for this asgent to attempt to satisfy.
func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float):
	objectives.append(Objective.build(goals, remove_after_satisfied, priority))


## An objective for the AI to try to solve for.
class Objective:
	## Goals to satisfy this objective.
	var goals:Dictionary
	## Whether to remove this goal after it is satisfied.
	var remove_after_satisfied:bool
	## Priority
	var priority:float
	
	static func build(g:Dictionary, rem:bool, p:float) -> Objective:
		var o = Objective.new()
		o.goals = g
		o.remove_after_satisfied = rem
		o.priority = p
		return o
	


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