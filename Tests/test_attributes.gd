extends GutTest


var e:Entity
var attributes_component:AttributesComponent


func before_each() -> void:
	e = autofree(Entity.new())
	e.add_child(AttributesComponent.new())
	attributes_component = e.get_component("AttributesComponent").unwrap()


func test_save() -> void:
	attributes_component.attributes[&"luck"] = 5
	var save_data = attributes_component.save()
	assert_eq(save_data[&"luck"], 5)


func test_load() -> void:
	var save_data = {
		&"perception" : 0,
		&"luck" : 5,
		&"amity" : 0,
		&"maxnomity" : 0,
		&"litheness" : 0,
	}
	
	attributes_component.load_data(save_data)
	assert_eq(attributes_component.attributes[&"luck"], 5)
