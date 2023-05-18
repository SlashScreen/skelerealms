extends GutTest


var victim:Entity
var perpetrator:Entity
var v_covens_component:CovensComponent
var p_covens_component:CovensComponent


func before_all() -> void:
	CovenSystem.add_coven(load("res://Tests/TestAssets/test_coven_1.tres"))
	CovenSystem.add_coven(load("res://Tests/TestAssets/test_coven_2.tres"))


func before_each() -> void:
	victim = autofree(Entity.new())
	victim.name = &"victim"
	victim.add_child(CovensComponent.new([load("res://Tests/TestAssets/test_coven_rank_data_1.tres") as CovenRankData]))
	v_covens_component = victim.get_component("CovensComponent").unwrap()
	
	perpetrator = autofree(Entity.new())
	perpetrator.name = &"perpetrator"
	perpetrator.add_child(CovensComponent.new([load("res://Tests/TestAssets/test_coven_rank_data_2.tres") as CovenRankData]))
	p_covens_component = victim.get_component("CovensComponent").unwrap()
	
	var em:EntityManager = autofree(EntityManager.new())
	em.add_child(victim)
	em.add_child(perpetrator)
	em.entities[&"victim"] = victim
	em.entities[&"perpetrator"] = perpetrator
	
	add_child(em)
	
	CrimeMaster.crimes.clear()


func test_add_crime() -> void:
	var crime = Crime.new(&"tomfoolery", &"perpetrator", &"victim")
	CrimeMaster.add_crime(crime)
	assert_eq(CrimeMaster.crimes[&"gut_test_coven_1"]["unpunished"].size(), 1)


func test_bounty() -> void:
	CrimeMaster.add_crime(Crime.new(&"tomfoolery", &"perpetrator", &"victim"))
	CrimeMaster.add_crime(Crime.new(&"assault", &"perpetrator", &"victim"))
	assert_eq(CrimeMaster.bounty_for_coven(&"perpetrator", &"gut_test_coven_1"), 10500)


func test_coven_opinion_change() -> void:
	CrimeMaster.add_crime(Crime.new(&"assault", &"perpetrator", &"victim"))
	assert_eq(CovenSystem.get_coven(&"gut_test_coven_1").get_crime_modifier(&"perpetrator"), -20)
