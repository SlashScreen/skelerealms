class_name TestConditionalGOAPBehavior
extends GOAPBehavior


func is_achievable() -> bool:
	return parent_goap.parent_entity.world == &"goap"
