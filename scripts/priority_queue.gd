extends RefCounted

# Yeah, I used claude to generate this. Sue me.

# Internal node structure to store priority-value pairs
class PQNode:
	var priority: float
	var value: Callable
	
	func _init(p: float, v: Callable):
		priority = p
		value = v

var _heap: Array[PQNode] = []

func _init():
	_heap = []

# Add a new item to the queue
func push(priority: float, value: Callable) -> void:
	var node = PQNode.new(priority, value)
	_heap.append(node)
	_bubble_up(_heap.size() - 1)

# Remove and return the highest priority item (lowest value)
func pop() -> Callable:
	if _heap.is_empty():
		push_error("Attempting to pop from empty priority queue")
		return Callable()
		
	var result = _heap[0].value
	
	# If this is the last element, just remove it
	if _heap.size() == 1:
		_heap.clear()
		return result
	
	# Otherwise, move last element to root and bubble down
	_heap[0] = _heap[-1]
	_heap.pop_back()
	_bubble_down(0)
	
	return result

# Get the highest priority item without removing it
func peek() -> PQNode:
	if _heap.is_empty():
		push_error("Attempting to peek empty priority queue")
		return PQNode.new(0.0, Callable())
	return _heap[0]

# Check if the queue is empty
func is_empty() -> bool:
	return _heap.is_empty()

# Get the current size of the queue
func size() -> int:
	return _heap.size()

# Helper function to maintain heap property when adding items
func _bubble_up(index: int) -> void:
	while index > 0:
		var parent_idx = (index - 1) / 2
		
		# If parent has higher priority value, swap them (min-heap)
		if _heap[parent_idx].priority > _heap[index].priority:
			var temp = _heap[parent_idx]
			_heap[parent_idx] = _heap[index]
			_heap[index] = temp
			index = parent_idx
		else:
			break

# Helper function to maintain heap property when removing items
func _bubble_down(index: int) -> void:
	while true:
		var smallest = index
		var left = 2 * index + 1
		var right = 2 * index + 2
		
		# Check if left child has lower priority value
		if left < _heap.size() and _heap[left].priority < _heap[smallest].priority:
			smallest = left
			
		# Check if right child has lower priority value
		if right < _heap.size() and _heap[right].priority < _heap[smallest].priority:
			smallest = right
			
		# If neither child has lower priority value, we're done
		if smallest == index:
			break
			
		# Otherwise, swap with the lower priority child
		var temp = _heap[index]
		_heap[index] = _heap[smallest]
		_heap[smallest] = temp
		index = smallest
