extends Control

func _ready():
	Globals.current_level=1
	Globals.upgrade1_equipped=false
	Globals.upgrade1=null
	Globals.hp_modifier=Globals.min_hp_modifier
	Globals.damage_modifier=Globals.min_damage_modifier
	Globals.boss_hp=100
	Globals.enemies_killed=0
	Globals.time={"hour":00,"minute":00,"second":00}

func _on_Play_pressed():
	get_tree().change_scene("res://Src/LevelSelect.tscn")
	
func _on_Quit_pressed():
	get_tree().quit()


func _on_Instruction_pressed():
	get_tree().change_scene("res://Src/Instructions.tscn")
