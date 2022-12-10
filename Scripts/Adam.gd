extends KinematicBody2D
#state variables
enum states{idle,move_left,move_right,jump,fall,crouch}
var current_state=states.idle
#movement variables
var velocity=Vector2.ZERO
var acceleration=Vector2(50,25)
var max_velocity=Vector2(200,400)
var jump_force=-500
var was_grounded=false
#HP and corruption 
var knockback=false
var HP=100 setget set_hp
var corruption=0 setget set_corruption
var is_dead=false
var is_possessed=false
var attacking=false
var can_fire=false
var has_holywater=false
var shield=0
var boss_fight=false
var holy_shield=false
#Scenes and instances
var fireball=preload("res://Src/Fireball.tscn")
signal player_dead
onready var hud_node=get_parent().get_node("HUD")
var rng=RandomNumberGenerator.new()
#Possessed Variables
var possess_walk_vel=Vector2(50,0)
var possess_walk_dir=1
var possess_speed=0


func _ready():
	randomize()
	rng.randomize()
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)

func is_on_ground():
	return $GroundCast1.is_colliding()	or $GroundCast2.is_colliding()

func horizontal_movement():
	if Input.is_action_pressed("Left"):
		velocity.x-=acceleration.x
		current_state=states.move_left
	elif Input.is_action_pressed("Right"):
		velocity.x+=acceleration.x
		current_state=states.move_right
	else:
		if current_state==states.move_left or current_state==states.move_right:
			current_state=states.idle
		if velocity.x!=0:
			velocity.x=velocity.x-acceleration.x if velocity.x>0 else velocity.x+acceleration.x
	
	velocity.x=clamp(velocity.x,-max_velocity.x,max_velocity.x)
		
func vertical_movement():
	
	if !is_on_ground() and was_grounded:
		$CoyoteTimer.start()
	
	if Input.is_action_pressed("Jump"):
		if is_on_ground() or !$CoyoteTimer.is_stopped():
			$CoyoteTimer.stop()
			velocity.y=jump_force
			current_state=states.jump
			$Jump.play()
			
	if Input.is_action_just_released("Jump") and velocity.y<-250:
		velocity.y=-250
	
	velocity.y+=acceleration.y
	velocity.y=clamp(velocity.y,jump_force,max_velocity.y)
	
	if current_state==states.jump and velocity.y>0:
		current_state=states.fall
	if current_state==states.fall and is_on_ground():
		current_state=states.idle

func crouch():
	if Input.is_action_just_pressed("Crouch") and is_on_ground():
		#Toggle crouch mode
		if !attacking:
			if current_state!=states.crouch:
				current_state=states.crouch
				$Hitbox/CollisionShape2D.shape.set_deferred("extents",Vector2(5.42,6.6))
				$Hitbox/CollisionShape2D.set_deferred("position",Vector2(0,8))
			else:
				current_state=states.idle
				$Hitbox/CollisionShape2D.shape.set_deferred("extents",Vector2(5.42,13.2))
				$Hitbox/CollisionShape2D.set_deferred("position",Vector2(0,0))
	
	if current_state==states.crouch:
		if !attacking:$AnimatedSprite.play("Crouch")
		if Input.is_action_just_pressed("Left"):
			$AnimatedSprite.flip_h=true
			$SlashArea.set_deferred("position",Vector2(-12,0))
		if Input.is_action_just_pressed("Right"):
			$AnimatedSprite.flip_h=false
			$SlashArea.set_deferred("position",Vector2(12,0))
		if Input.is_action_just_pressed("LMB") and !attacking:
			$AnimatedSprite.play("CrouchSlash")
			$SlashArea/CollisionShape2D.set_deferred("disabled",false)
			attacking=true
		move_and_slide(Vector2(0,200))

func attack():
	#Fireball
	if Input.is_action_just_pressed("RMB") and can_fire:
		var fireball_instance=fireball.instance()
		fireball_instance.global_position=global_position
		fireball_instance.velocity=global_position.direction_to(get_global_mouse_position())*4
		get_parent().add_child(fireball_instance)
		corruption+=5
		$Shoot.play()
	
	if Input.is_action_just_pressed("LMB") and !attacking:
		$AnimatedSprite.play("Slash")
		$SlashArea/CollisionShape2D.set_deferred("disabled",false)
		attacking=true
		$SlashSound.play()
		
	
func animation():	
	if !$AnimatedSprite.animation=="Slash":
		if current_state==1 or current_state==2:
				$AnimatedSprite.play("Run")
		elif current_state==0 or current_state==3 or current_state==4:
				$AnimatedSprite.play("Idle")
	
	if velocity.x<0:
		$AnimatedSprite.flip_h=true
		$SlashArea.set_deferred("position",Vector2(-12,0))
	elif velocity.x>0:
		$AnimatedSprite.flip_h=false
		$SlashArea.set_deferred("position",Vector2(12,0))


func possess_movement():
	if HP<=0 or global_position.y>600:
		$PossessTime.stop()
		$AnimatedSprite.modulate=Color(1,1,1,1)
		is_possessed=false
		hud_node.get_node("PossessedLabel").visible=false
		hud_node.get_node("PossessedTime").visible=false
		is_dead=true
		$AnimatedSprite.play("Death")
		$SlashArea/CollisionShape2D.disabled=true
	if !is_dead:
		if rng.randi_range(1,50)==7:
			possess_walk_dir=-possess_walk_dir
		if rng.randi_range(1,40)==7 and is_on_ground():
			possess_walk_vel.y=jump_force+50
		if rng.randi_range(1,100)==7:
			$AnimatedSprite.play("Slash")
			$SlashArea/CollisionShape2D.set_deferred("disabled",false)
			attacking=true
		possess_walk_vel.y+=50
		possess_walk_vel.y=clamp(possess_walk_vel.y,jump_force,400)
		if possess_walk_dir==-1:
			$AnimatedSprite.flip_h=true
			$SlashArea.set_deferred("position",Vector2(-12,0))
		else:
			$AnimatedSprite.flip_h=false
			$SlashArea.set_deferred("position",Vector2(12,0))
		move_and_slide(Vector2(possess_walk_vel.x*possess_speed*possess_walk_dir,possess_walk_vel.y))


func hit(body,dmg,knock=null):
	if current_state==states.crouch and holy_shield:
		return
	if !knockback:
		knockback=true
		if knock==null:
			#global_position.x=(global_position+body.global_position.direction_to(global_position)*25).x
			move_and_collide(Vector2((body.global_position.direction_to(global_position)*25).x,0))
		else:
			#global_position+=knock
			move_and_collide(knock)
		$KnockbackTimer.start()
		if shield==0:
			$HurtSound.play()
			$AnimatedSprite.material.set_shader_param("flash_modifier",1)
			if body.name!="Azazel":
				HP-=dmg*Globals.hp_modifier
			else:
				HP-=dmg*0.5
		elif shield>0:
			shield-=1
			if shield==0:
				get_parent().get_node("HUD").get_node("Upgrade1").texture=null


func _physics_process(delta):
	if !is_dead and !is_possessed:
		corruption+=0.05
		if current_state!=states.crouch:
			horizontal_movement()
			vertical_movement()
			attack()
		crouch()
		animation()
		if boss_fight:
				corruption=0
		
		if global_position.y>600 or HP<=0:
			is_dead=true
			$AnimatedSprite.play("Death")
			$SlashArea/CollisionShape2D.disabled=true
		if corruption>=100 and !is_possessed:
			$PossessSound.play()
			$Smoke.emitting=true
			$AnimatedSprite.play("Run")
			$AnimatedSprite.modulate=Color(1,0.3,0.3,1)
			is_possessed=true
			$PossessTime.wait_time=rng.randi_range(1,3)
			$PossessTime.start()
			hud_node.get_node("PossessedLabel").visible=true
			hud_node.get_node("PossessedTime").visible=true
			hud_node.get_node("PossessedTime").max_value=$PossessTime.wait_time
			hud_node.get_node("PossessedTime").value=$PossessTime.wait_time
			possess_speed=rng.randi_range(2,5)
			possess_walk_dir=1 if rng.randi_range(1,2)==2 else -1	
		
		if current_state!=states.crouch:
			velocity.y=move_and_slide(velocity,Vector2.UP).y
			was_grounded=is_on_ground()
	
	elif is_possessed:
		hud_node.get_node("PossessedTime").value=$PossessTime.time_left
		possess_movement()
	

				
func _on_PossessTime_timeout():
	attacking=false
	current_state=states.idle
	$Smoke.emitting=false
	$AnimatedSprite.play("Idle")
	$AnimatedSprite.modulate=Color(1,1,1,1)
	is_possessed=false
	hud_node.get_node("PossessedLabel").visible=false
	hud_node.get_node("PossessedTime").visible=false
	corruption=0
	


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation=="Death":
		$Die.play()
		emit_signal("player_dead")
	elif $AnimatedSprite.animation=="Slash":
		attacking=false
		if !is_possessed:
			$AnimatedSprite.play("Idle")
		else:
			$AnimatedSprite.play("Run")
		$SlashArea/CollisionShape2D.set_deferred("disabled",true)
	elif $AnimatedSprite.animation=="CrouchSlash":
		$SlashArea/CollisionShape2D.set_deferred("disabled",true)
		attacking=false
		$AnimatedSprite.play("Crouch")


func _on_SlashArea_body_entered(body):
	if body.name=="Azazel":
		body.hit(self,2.5)
	else:
		body.hit(self,25,(body.global_position+global_position.direction_to(body.global_position)*25))


func _on_KnockbackTimer_timeout():
	knockback=false
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)
	


func _on_SlashArea_area_entered(area):
	if area.has_method("hit"):
		if area.type=="FlyingEnemy":
			area.hit(self,100,0)


func set_corruption(val):
	if has_holywater:
		corruption=corruption+(val-corruption)*0.5
	else:
		corruption=val


func set_hp(val):
	if has_holywater:
		HP=HP-((HP-val)*1.5)
	else:
		HP=val


