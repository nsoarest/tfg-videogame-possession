extends Control



func _on_ContinueButton_pressed():
	get_tree().change_scene("res://Src/Menu.tscn")


func _on_StatsButton_pressed():
	$Stats/Enemies.bbcode_text="[center]Enemies Killed: "+str(Globals.enemies_killed)+ "[/center]"
	var hours=OS.get_time().hour-Globals.time.hour
	var mins=OS.get_time().minute-Globals.time.minute
	var sec=OS.get_time().second-Globals.time.second
	var time=str(hours)+"h "+str(mins)+"m "+str(sec)+"s"
	$Stats/Time.bbcode_text="[center]Time Played: "+time+"[/center]"
	$Stats.popup()
