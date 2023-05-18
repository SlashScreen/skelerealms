extends GutTest


var e:Entity
var skills_component:SkillsComponent


func before_each() -> void:
	e = autofree(Entity.new())
	e.add_child(SkillsComponent.new())
	skills_component = e.get_component("SkillsComponent").unwrap()


func test_default_level() -> void:
	skills_component.skills = {
		&"short_blade" : 1,
		&"long_blade" : 2,
		&"blunt" : 3,
	}
	assert_eq(skills_component.level, 6, "Should pass. Default level totals skills, which is 6.")


func test_manual_level() -> void:
	skills_component.level = 10
	assert_eq(skills_component.level, 10, "Should pass. Manual level set to 10.")


func test_save_default() -> void:
	skills_component.skills = {
		&"short_blade" : 1,
		&"long_blade" : 2,
		&"blunt" : 3,
	}
	
	var save_data = skills_component.save()
	assert_eq(save_data, {
		"skills": {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		},
		"level": -1
	})


func test_save_manual() -> void:
	skills_component.skills = {
		&"short_blade" : 1,
		&"long_blade" : 2,
		&"blunt" : 3,
	}
	skills_component.level = 10
	
	var save_data = skills_component.save()
	assert_eq(save_data, {
		"skills": {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		},
		"level": 10
	})


func test_load_default() -> void:
	var save_data = {
		"skills": {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		},
		"level": -1
	}
	
	skills_component.load_data(save_data)
	assert_eq(skills_component.skills, {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		})
	assert_eq(skills_component.level, 6)


func test_load_manual() -> void:
	var save_data = {
		"skills": {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		},
		"level": 10
	}
	
	skills_component.load_data(save_data)
	assert_eq(skills_component.skills, {
			&"short_blade" : 1,
			&"long_blade" : 2,
			&"blunt" : 3,
		})
	assert_eq(skills_component.level, 10)
