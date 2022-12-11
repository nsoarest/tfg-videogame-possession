extends Area2D

export var scene="res://Src/UpgradesLvl1.tscn"


func _process(delta):
	var bodies=get_overlapping_bodies()
	for body in bodies:
		if body.name=="Adam":
			if !body.is_dead:
				Globals.current_level+=1
				get_tree().change_scene(scene)
