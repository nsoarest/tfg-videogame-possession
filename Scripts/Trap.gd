extends StaticBody2D

export var durability=100
export var damage=25

func _process(delta):
	var bodies=$Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.name=="Adam":
			if !body.is_dead:
				body.velocity.y=0
				body.current_state=0
				body.hit(self,damage,Vector2(0,-55))
			
	if durability<=0:
		queue_free()


func reduce_durability(amount):
	durability-=amount

