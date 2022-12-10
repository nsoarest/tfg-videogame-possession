extends Control

func _ready():
	Globals.upgrade1_equipped=false
	Globals.upgrade1=null
	Globals.hp_modifier=Globals.min_hp_modifier
	var damage_modifier=Globals.min_damage_modifier

func _on_Play_pressed():
	get_tree().change_scene("res://Src/LevelSelect.tscn")
	
func _on_Quit_pressed():
	get_tree().quit()


func _on_Instruction_pressed():
	get_tree().change_scene("res://Src/Instructions.tscn")
