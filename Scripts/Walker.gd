extends KinematicBody2D

onready var player=get_parent().get_parent().get_node("Adam")

var current_state=0
var target
var velocity=Vector2.ZERO
var knockback=false
var bodies
var prev_vel=0
var type="WalkingEnemy"
var slash_scene=preload("res://Src/ClawSlash.tscn")
var random=RandomNumberGenerator.new()
var seal_scene=preload("res://Src/Seal.tscn")
var hp_scene=preload("res://Src/HealthPickup.tscn")

export var damage=25
export var health=100
export var max_speed=Vector2(80,-700)
export var rng=250
enum States{idle,chase}


func _ready() -> void:
	random.randomize()
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)
	$AnimatedSprite.animation="Idle"
	$AnimatedSprite.play()


func _physics_process(delta: float) -> void:
	
	if $AnimatedSprite.animation!="Die":
		state_check()
		perform_state()
	
		bodies=$HitBox.get_overlapping_bodies()
		for body in bodies:
			if body.name=="Adam":
				if !body.knockback:
					var slash_instance=slash_scene.instance()
					slash_instance.global_position=body.global_position
					slash_instance.flip_h=$AnimatedSprite.flip_h
					slash_instance.damage=damage
					get_parent().get_parent().add_child(slash_instance)
					
		
	velocity.y+=30		
	velocity.y=move_and_slide(velocity,Vector2.UP).y
		


func state_check():
	if global_position.distance_to(player.global_position)<rng:
		current_state=States.chase
		$AnimatedSprite.animation="Walk"
		$AnimatedSprite.play()
		target=player.global_position
		$ReactionTime.start()
	else:
		current_state=States.idle
		velocity.x=0
		$AnimatedSprite.animation="Idle"
		$AnimatedSprite.play()
		$ReactionTime.stop()
		

func perform_state():

	if current_state==States.chase:
		if abs(target.x-global_position.x)>50:
			if target.x>global_position.x:
				velocity.x=max_speed.x
			if target.x<global_position.x:
				velocity.x=-max_speed.x
		if !($WallCast.is_colliding()) or is_on_wall():
			if is_on_floor():
				velocity.y=max_speed.y
		flip()
	
	
func hit(body,dmg,knock):
	if not(knockback):
		prev_vel=velocity.x
		velocity.x=0
		$AnimatedSprite.play("Idle")
		global_position.x=knock.x
		#move_and_collide(Vector2(,0))
		$AnimatedSprite.material.set_shader_param("flash_modifier",1)
		$KnockbackTimer.start()
		health-=dmg
		$HurtSound.play()
		knockback=true
		if health<=0:
			$HitBox/CollisionShape2D.set_deferred("disabled",true)
			$AnimatedSprite.animation="Die"
			velocity.x=0
		
			
func flip():
	if velocity.x>0:
		$AnimatedSprite.flip_h=true
		$CollisionShape2D.position.x=-3
		$WallCast.position.x=12
		$HitBox/CollisionShape2D.position.x=-1
	elif velocity.x<0:
		$AnimatedSprite.flip_h=false
		$CollisionShape2D.position.x=3
		$WallCast.position.x=-12
		$HitBox/CollisionShape2D.position.x=1


func _on_KnockbackTimer_timeout() -> void:
	if $AnimatedSprite.animation!="Die":
		knockback=false
		velocity.x=prev_vel
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation=="Die":
		leave_pickups()
		queue_free()
		

func _on_ReactionTime_timeout() -> void:
	if current_state==States.chase:
		target=player.global_position


func leave_pickups():
	if random.randi_range(1,8)==4:
		var seal_inst=seal_scene.instance()
		seal_inst.global_position=global_position
		get_parent().get_parent().add_child(seal_inst)
	elif random.randi_range(1,10)==4:
		var hp_inst=hp_scene.instance()
		hp_inst.global_position=global_position
		get_parent().get_parent().add_child(hp_inst)


