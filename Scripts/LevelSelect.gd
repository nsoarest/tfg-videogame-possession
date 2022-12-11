extends Control



func _on_Level1_pressed():
	Globals.time=OS.get_time()
	get_tree().change_scene("res://Src/StartStory.tscn")



func _on_Level2_pressed():
	Globals.time=OS.get_time()
	Globals.current_level=2
	get_tree().change_scene("res://Src/UpgradesLvl1.tscn")
	
	
	
func _on_Boss_pressed():
	Globals.time=OS.get_time()
	Globals.current_level=3
	get_tree().change_scene("res://Src/UpgradesLvl1.tscn")
