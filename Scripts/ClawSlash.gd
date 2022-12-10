extends AnimatedSprite

var damage=25


func _ready():
	play("Slash")
	

func _on_ClawSlash_animation_finished():
	get_parent().get_node("Adam").hit(self,damage)
	queue_free()
