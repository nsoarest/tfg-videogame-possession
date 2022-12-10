extends StaticBody2D

var bodies
var durability=100
var type="Skull"
var seal_scene=preload("res://Src/Seal.tscn")
var hp_scene=preload("res://Src/HealthPickup.tscn")
var pickup
var random=RandomNumberGenerator.new()


func _ready():
	random.randomize()
	

func _process(delta):
	if durability<=0:
		leave_pickups()
		queue_free()
	
	bodies=$Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.name=="Adam":
			if !body.is_dead:
				body.corruption+=0.6
				body.HP-=0.2
				body.corruption=clamp(body.corruption,0,100)

func reduce_durability(amount):
	durability-=amount


func leave_pickups():
	if random.randi_range(1,2)==1:
		pickup=seal_scene.instance()
	else:
		pickup=hp_scene.instance()
	pickup.global_position=Vector2(global_position.x,global_position.y-5)
	get_parent().get_parent().add_child(pickup)
