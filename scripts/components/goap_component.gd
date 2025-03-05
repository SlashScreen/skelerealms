class_name GOAPComponent
extends SKEntityComponent
## Component that implements Goal-Oriented Action Planning (GOAP) for entity AI behavior.
## Creates and executes sequences of actions to achieve specified objectives based on current world state.

var agent_state:Dictionary = {}  ## Current state of the AI agent
var objectives:Array[Objective] = []  ## List of objectives the agent is trying to achieve
var action_queue:Array[GOAPAction] = []  ## Queue of actions planned to achieve the current objective

var _current_action:GOAPAction  ## The action currently being executed
var _current_objective:Objective  ## The objective currently being worked on
var _agent:NavigationAgent3D  ## Navigation agent for pathfinding
var _invoked:bool  ## Whether a timed action is currently in progress
var _timer:Timer  ## Timer for action durations
var _rebuild_plan:bool  ## Flag indicating if the action plan needs to be rebuilt


func _init() -> void:
	name = &"GOAPComponent"
	# add timer
	_timer = Timer.new()
	_timer.name = "Timer"
	_timer.one_shot = true
	add_child(_timer)


func _ready() -> void:
	for a:Node in get_children():
		if a is GOAPAction:
			a.entity = parent_entity
			a.parent_goap = self


func _process(delta:float) -> void:
	if GameInfo.is_loading:
		return
	# if we are set to rebuild our plan
	if _rebuild_plan:
		# Find the highest priority objective
		objectives.sort_custom(func(a:Objective, b:Objective): return a.priority > b.priority)
		for o in objectives:
			action_queue = _plan(get_children()\
				.filter(func(x): return x is GOAPAction)\
				.map(func(x): return x as GOAPAction), o.goals, {}\
			)
			# if we made a plan, stop sorting through objectives
			if not action_queue.is_empty():
				_pop_action()
				_current_objective = o
				_rebuild_plan = false
				break
	
	# if we are done with the plan
	if _current_objective and not _rebuild_plan and action_queue.is_empty() and not _current_action:
		# if we need to remove the objective, remove it
		if _current_objective.remove_after_satisfied:
			objectives.erase(_current_objective)
		# trigger plan rebuild next frame
		_rebuild_plan = true
	
	# if we are not done with the current action
	if not _current_action == null: 
		if _current_action.running:
			if _current_action.is_target_reached(_agent): # if agent navigation is finished
				if not _invoked: # if we aren't actively waiting for an action to be completed
					if _current_action.target_reached(): # call the target reached callback
						_invoke_in_time(_complete_current_action.bind(), _current_action.duration)
					else:
						_rebuild_plan = true
		else:
			if not action_queue.is_empty():
				_pop_action()
			else:
				_rebuild_plan = true


## Starts execution of the next action in the queue
func _pop_action() -> void:
	_current_action = action_queue.pop_back()
	_current_action.running = true
	# if pre perform fails, rebuild plan
	if not _current_action.pre_perform():
		_rebuild_plan = true


## Creates a plan to satisfy a set of goals using available actions
## [param actions] List of available GOAPActions
## [param goal] Dictionary of desired world states
## [param world_states] Current world states
## [returns] Array of GOAPActions that will achieve the goal, or empty if no plan found
func _plan(actions:Array, goal:Dictionary, world_states:Dictionary) -> Array[GOAPAction]:
	var action_pool:Array = actions.filter(func(a:GOAPAction): return a.is_achievable())
	
	var leaves:Array[PlannerNode] = []
	var start = PlannerNode.new(null, world_states, null, 0)
	var success = _build_graph(start, leaves, goal, action_pool)
	
	if not success: # if we have not found a path, we have failed.
		return []
		
	leaves.sort_custom(func(a:PlannerNode,b:PlannerNode): return a.cost < b.cost ) #Sort to find valid node with least cost.
	var cheapest:PlannerNode = leaves[0]
	
	var new_plan:Array[GOAPAction] = [] # create the plan for the AI to use. This will be treated like a queue.
	# walk back up the parent chain that the selected node has kept (sorta like a linked list) and build a queue from that.
	var n = cheapest 
	while not n.parent == null:
		new_plan.push_back(n.action)
		n = n.parent
	
	#new_plan.reverse()
	return new_plan


## Recursively builds a graph of possible action sequences to achieve the goal
## [param parent] Parent node in the planning graph
## [param leaves] Array to store valid goal-achieving paths
## [param goal] Dictionary of desired world states
## [param action_pool] Available actions for planning
## [returns] Whether a valid path was found
func _build_graph(parent:PlannerNode, leaves:Array[PlannerNode], goal:Dictionary, action_pool:Array) -> bool:
	var found_path:bool = false
	# FIXME: We need to be doing breadth first search
	
	# get all actions that are 
	# 1) achievable
	# 2) achievable given prerequisites
	# 3) has not already had effects satisfied <- may cause issues
	var achievable_actions = action_pool.filter(func(x:GOAPAction): return x.is_achievable() and x.is_achievable_given(parent.states) and not parent.states.has_all(x.get_effects().keys()))
	achievable_actions.sort_custom(func(a,b): return a.cost < b.cost ) #Sort to resolve actions with least cost first.
	
	# due to the recursive nature of this function, we will be building branching paths from all of the actions until a valid path is found.
	for action:GOAPAction in achievable_actions:
		# if we can achieve this action,
		# duplicate our working set of states.
		var current_state:Dictionary = parent.states.duplicate(true)
		
		# Continue to accumulate effects in state, for passing on to the next node.
		current_state.merge(action.get_effects(), true) # overwrite to keep the state up to date.
			
		# create a new child planner node, which will have an accumulation of all the previous costs.
		# this will help us find the shortest path later.
		var next_node:PlannerNode = PlannerNode.new(parent, current_state, action, parent.cost + action.cost)
		
		if _goal_achieved(goal, current_state):
			# if we have reached the state we are looking for, append the node to the leaves, and set found_path.
			leaves.append(next_node)
			found_path = true
		else:
			# if we have not reached the goal,
			# create a subset of the action pool that removes the current action.
			# this will prevent circular action chains.
			var subset:Array = action_pool.duplicate() # no deep copy, we don't want to clone the nodes.
			subset.erase(action)
			
			# then, recurse and find the next possible node.
			if _build_graph(next_node, leaves, goal, subset):
				found_path = true
	
	return found_path


## Checks if all goal states have been achieved
## [param goal] Dictionary of desired world states
## [param current_state] Current world states
## [returns] Whether all goals are satisfied
func _goal_achieved(goal:Dictionary, current_state:Dictionary) -> bool:
	return current_state.has_all(goal.keys())


## Schedules a function call after a delay
## [param f] The function to call
## [param time] Delay in seconds before calling
func _invoke_in_time(f:Callable, time:float) -> void:
	if time == 0:
		f.call()
		return
	
	_invoked = true
	_timer.start(time)
	_timer.timeout.connect(func():
		_clear_timer()
		f.call()
	)


## Cleans up timer connections
func _clear_timer() -> void:
	for c in _timer.timeout.get_connections():
		_timer.timeout.disconnect(c.callable)


## Finalizes the current action and checks if plan needs to be rebuilt
func _complete_current_action() -> void:
	_current_action.running = false
	if not _current_action.post_perform():
		_rebuild_plan = true
	_invoked = false


## Adds a new objective for the agent to pursue
## [param goals] Dictionary of desired world states
## [param remove_after_satisfied] Whether to remove the objective once completed
## [param priority] Priority level of the objective (higher numbers = higher priority)
## [returns] The created Objective instance
func add_objective(goals:Dictionary, remove_after_satisfied:bool, priority:float) -> Objective:
	var o = Objective.new(goals, remove_after_satisfied, priority)
	objectives.append(o)
	_rebuild_plan = true
	return o


## Removes objectives that match the specified goals
## [param goals] Dictionary of goal states to match for removal
func remove_objective_by_goals(goals:Dictionary) -> void:
	var to_remove = objectives.filter(func(x:Objective): return x.goals == goals)
	for o in to_remove:
		objectives.erase(o)


## Forces the agent to rebuild its action plan
func regenerate_plan() -> void:
	_rebuild_plan = true


## Interrupts the current action and forces a plan rebuild
func interrupt() -> void:
	if _current_action:
		_current_action.interrupt()
		_timer.stop()
	regenerate_plan()


## Generates a detailed debug string of the component's current state
## [returns] Formatted string containing current objectives, actions, and timing information
func gather_debug_info() -> String:
	return """
[b]GOAPComponent[/b]
	Objectives: %s
	Current objective: %s
	Current action: %s (Running: %s)
	Action queue: %s
	Current action duration: %s
	Remaining action time: %s / %s (Timer running: %s)
	Target reached: %s (Final point: %s, Target Distance: %s)
""" % [
	objectives\
		.map(func(o:Objective): return o.serialize())\
		.reduce(func(sum, next): return sum + next, ""),
	_current_objective.serialize() if _current_objective else "None",
	_current_action.name if _current_action else "None",
	_current_action.running if _current_action else "false",
	" -> ".join(
		(
			func():
				var x = action_queue.map(func(action:GOAPAction): return action.name)
				x.reverse()
				return x
				).call()
		),
	-1 if _current_action == null else _current_action.duration,
	_timer.time_left,
	_timer.wait_time,
	not _timer.is_stopped(),
	"No agent" if _agent == null else _agent.is_target_reached(),
	"No agent" if _agent == null else _agent.get_final_position(),
	"No agent" if _agent == null else _agent.target_desired_distance
]


## An objective for the AI to try to solve for.
class Objective:
	## Goals to satisfy this objective.
	var goals:Dictionary
	## Whether to remove this goal after it is satisfied.
	var remove_after_satisfied:bool
	## Priority
	var priority:float
	
	func _init(g:Dictionary, rem:bool, p:float) -> void:
		goals = g
		remove_after_satisfied = rem
		priority = p
	
	func serialize() -> String:
		return """
		Remove after satisfied: %s
		Priority: %s
		Goals: %s
		""" % [
			remove_after_satisfied,
			priority,
			JSON.stringify(goals, '\t')
		]


## Internal node for planning a GOAP chain.
class PlannerNode:
	var parent:PlannerNode
	var action:GOAPAction
	var cost:float
	var states:Dictionary
	
	
	func _init(p:PlannerNode, s:Dictionary, a:GOAPAction, c:float) -> void:
		parent = p
		action = a
		cost = c
		states = s
