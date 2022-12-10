extends Area2D

var velocity=Vector2.ZERO
var explosion_scene=preload("res://Src/Explosion.tscn")
var explosion_scale=0.5

func _ready():
	$Particles2D.process_material.direction=Vector3(-velocity.normalized().x,-velocity.normalized().y,0)


func _process(delta):
	global_position+=velocity
	

func _on_Fireball_body_entered(body):
	if body.has_method("hit"):
		if body.name=="Azazel":
				if body.invincible:
					return
				body.hit(self,1)
		elif body.health>0:
			body.hit(self,50,body.global_position+velocity)
	elif body.has_method("reduce_durability"):
		if body.type=="Skull":
			body.reduce_durability(50)		
	explode()
	

func explode():
	var explosion_instance=explosion_scene.instance()
	explosion_instance.global_position=global_position-velocity
	explosion_instance.scale=Vector2(explosion_scale,explosion_scale)
	get_parent().add_child(explosion_instance)
	queue_free()



func _on_Fireball_area_entered(area):
	if area.has_method("hit"):
		if area.type=="FlyingEnemy":
			area.hit(self,100,area.global_position+velocity)
			explode()
	elif area.get_parent().has_method("reduce_durability"):
		area.get_parent().reduce_durability(50)
		explode()
		
