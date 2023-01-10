extends Node2D

func _ready():
	Globals.boss_fights+=1
	$Adam.boss_fight=true
	$Adam/Camera2D.offset=Vector2(0,-55)
	$HUD/BossHealth.visible=true
	$HUD/BossName.visible=true
	$HUD/WinTime.visible=true
	$HUD/WinTime.max_value=$WinTimer.wait_time

	
func _process(delta):
	if $Azazel!=null:
		$HUD/BossHealth.value=$Azazel.HP
		$HUD/WinTime.value=$WinTimer.time_left	
	else:
		get_tree().change_scene("res://Src/EndStory.tscn")


func _on_Adam_player_dead():
	loose()


func _on_WinTimer_timeout():
	Globals.boss_hp=$Azazel.HP
	get_tree().change_scene("res://Src/MiniGame.tscn")

	
func loose():
	$WinTimer.stop()
	Globals.hp_modifier+=0.1
	Globals.hp_modifier=clamp(Globals.hp_modifier,Globals.min_hp_modifier,Globals.max_hp_modifier)
	Globals.damage_modifier+=0.5
	Globals.damage_modifier=clamp(Globals.damage_modifier,Globals.min_damage_modifier,Globals.max_damage_modifier)
	$HUD/LoseLabel.visible=true
	$HUD/LoseButton.visible=true
	$HUD/LoseButton2.visible=true


