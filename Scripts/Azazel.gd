extends KinematicBody2D

export var speed=150
export var damage=50
onready var player=get_parent().get_node("Adam")
var projectile=preload("res://Src/EnemyProjectile.tscn")
var claw_slash=preload("res://Src/ClawSlash.tscn")
var hp_scene=preload("res://Src/HealthPickup.tscn")
var rng=RandomNumberGenerator.new()
var velocity=Vector2.ZERO
var is_dead=false
var current_state=0
var knockback=false
export var HP=100
var invincible=false
enum states{roam,range_attack,melee_attack}



func _ready():
	rng.randomize()
	$AttackTimer.wait_time=rng.randi_range(5,8)
	$AttackTimer.start()
	current_state=states.roam
	invincible=true
	velocity.x=speed
	$AnimatedSprite.play("Fly")
	HP=Globals.boss_hp
	


func _physics_process(delta):
	state_check()
	perform_state()	
	if HP<=0 and !is_dead:
		$DieSound.play()
		is_dead=true



func state_check():
	pass


func perform_state():
	
	if current_state==states.roam:
		if global_position.y>32:
			velocity.y=-40
		else:
			velocity.y=0
		if is_on_wall():
			velocity.x=-velocity.x	
			
	elif current_state==states.range_attack:
		if is_on_wall():
			velocity.x=-velocity.x				
			
	elif current_state==states.melee_attack:
		if is_on_floor():
			collision_mask=3
			velocity=Vector2.ZERO
			$AnimatedSprite.play("Idle")
			$SlashTime.start()
	
	
	flip_image()		
	move_and_slide(velocity,Vector2.UP)

	
	
func state_transition(state):
	current_state=state	
	if current_state==1 or current_state==2:
		invincible=false
		$AnimatedSprite.modulate=Color(1,1,1,1)
		if current_state==states.range_attack:
			velocity.x=velocity.x*1.5
			collision_mask=3
			$RangeAttack.start()
		elif current_state==states.melee_attack:
			$SlashArea/CollisionShape2D.set_deferred("disabled",false)
			velocity=global_position.direction_to(player.global_position)*250
			if player.global_position.x>global_position.x:
				$AnimatedSprite.flip_h=false
				$SlashArea.set_deferred("position",Vector2(25,6))
			elif player.global_position.x<global_position.x:
				$AnimatedSprite.flip_h=true
				$SlashArea.set_deferred("position",Vector2(-25,6))
				
	else:
		invincible=true
		collision_mask=1
		velocity.x=velocity.x/1.5 if velocity.x!=0 else 150
		$AnimatedSprite.modulate=Color(0.26,0.26,0.26,0.53)
		$AnimatedSprite.play("Fly")
		$RangeAttack.stop()
		$SlashArea/CollisionShape2D.set_deferred("disabled",true)
		

func _on_AttackTimer_timeout():
	
	var random_state=rng.randi_range(1,2)
	if random_state==1:
		$AttackDuration.wait_time=rng.randi_range(3,5)
	elif random_state==2:
		$AttackDuration.wait_time=3
	$AttackDuration.start()
	state_transition(random_state)


func _on_AttackDuration_timeout():
	$AttackTimer.wait_time=rng.randi_range(5,8)
	$AttackTimer.start()
	state_transition(0)


func flip_image():
	if velocity.x>0:
		$AnimatedSprite.flip_h=false
	elif velocity.x<0:
		$AnimatedSprite.flip_h=true



func _on_RangeAttack_timeout():
	var proj_inst=projectile.instance()
	proj_inst.global_position=global_position
	proj_inst.speed=3.5
	proj_inst.get_node("Sprite").modulate=Color(1,0,0,1)
	get_parent().add_child(proj_inst)
	$Shoot.play()
	

func _on_SlashArea_body_entered(body):
	if body.name=="Adam":
		var claw_inst=claw_slash.instance()
		claw_inst.global_position=player.global_position
		claw_inst.damage=damage*Globals.damage_modifier
		claw_inst.flip_h=true if player.global_position.x>global_position.x else false
		claw_inst.material.set_shader_param("flash_modifier",1)
		claw_inst.speed_scale=1.5
		claw_inst.scale=Vector2(2,2)
		get_parent().add_child(claw_inst)


func _on_SlashTime_timeout():
	$SlashArea/CollisionShape2D.set_deferred("disabled",true)


func hit(body,dmg):
	if !knockback and !invincible:
		knockback=true
		$AnimatedSprite.material.set_shader_param("flash_modifier",1)
		$KnockbackTimer.start()
		HP-=dmg
		$HurtSound.play()
		if rng.randi_range(1,12)==7:
			var hp_inst=hp_scene.instance()
			hp_inst.global_position=Vector2(rng.randi_range(-80,160),7*16)
			get_parent().add_child(hp_inst)



func _on_KnockbackTimer_timeout():
	knockback=false
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)


func _on_DieSound_finished():
	queue_free()
