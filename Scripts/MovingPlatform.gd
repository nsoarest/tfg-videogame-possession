extends StaticBody2D

export var speed=2
onready var path_follow=get_parent()


func _process(delta):
	path_follow.offset+=speed
	
	if path_follow.unit_offset==0 or path_follow.unit_offset==1:
		speed=-speed	

