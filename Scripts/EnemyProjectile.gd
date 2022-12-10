extends Area2D

var velocity=Vector2.ZERO
var speed=5
var explosion_scene=preload("res://Src/Explosion.tscn")
var explosion_scale=0.5

func _ready():
	if velocity==Vector2.ZERO:
		velocity=global_position.direction_to(get_parent().get_node("Adam").global_position)*speed


func _process(delta):
	global_position+=velocity


func explode():
	var explosion_instance=explosion_scene.instance()
	explosion_instance.global_position=global_position-velocity
	explosion_instance.modulate=Color(0.8,0.18,0.48,1)
	explosion_instance.scale=Vector2(explosion_scale,explosion_scale)
	get_parent().add_child(explosion_instance)
	queue_free()


func _on_EnemyProjectile_area_entered(area):
	if area.name!="SlashArea":
		if area.get_parent().name=="Adam":
			area.get_parent().hit(self,25)
		explode()


func _on_EnemyProjectile_body_entered(body):
	#Explode on contact with the ground
	if body.name!="Adam":
		explode()
