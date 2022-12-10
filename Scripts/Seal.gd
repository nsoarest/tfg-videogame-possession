extends Area2D

func _ready():
	$Timer.start()

func _process(delta):
	var bodies=get_overlapping_bodies()
	for body in bodies:	
		if body.name=="Adam" and $Timer.is_stopped():
			body.corruption=0
			body.corruption=clamp(body.corruption,0,100)
			body.get_node("Pickup").play()
			queue_free()
