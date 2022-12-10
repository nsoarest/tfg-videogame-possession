extends Control



func _on_Level1_pressed():
	get_tree().change_scene("res://Src/StartStory.tscn")




func _on_Level2_pressed():
	get_tree().change_scene("res://Src/UpgradesLvl1.tscn")
	
	
	
func _on_Boss_pressed():
	Globals.upgrade1="FIREBALLS"
	Globals.upgrade1_equipped=true
	get_tree().change_scene("res://Src/UpgradesLvl1.tscn")
