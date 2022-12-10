extends AnimatedSprite

func _ready():
	play("Explode")
	


func _on_Explosion_animation_finished():
	queue_free()
