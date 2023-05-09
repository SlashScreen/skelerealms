extends SpellEffect


const TIMER_MAX = 1.1

var dc:DamageableComponent
var timer = 0;


func apply(stc:SpellTargetComponent) -> void:
	super.apply(stc)
	target.parent_entity.get_component("DamageableComponent").bind(func(x:DamageableComponent): dc = x)


func on_update(delta:float) -> void:
	# TODO: Caster
	dc.damage(DamageInfo.new("", {&"poison":delta}))
	timer += delta
	if timer >= TIMER_MAX:
		target.remove_effect(self)
