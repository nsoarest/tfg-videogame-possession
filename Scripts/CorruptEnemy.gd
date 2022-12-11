extends KinematicBody2D

onready var player=get_parent().get_parent().get_node("Adam")

var current_state=0
var target
var velocity=Vector2.ZERO
var knockback=false
var bodies
var prev_vel=0
var type="CorruptEnemy"
var projectile=preload("res://Src/EnemyProjectile.tscn")
var seal_scene=preload("res://Src/Seal.tscn")
var hp_scene=preload("res://Src/HealthPickup.tscn")
var random=RandomNumberGenerator.new()
var pickup

export var damage=50
export var health=100
export var max_speed=Vector2(30,-500)
export var rng=150
enum States{idle,chase}


func _ready() -> void:
	random.randomize()
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)
	$AnimatedSprite.animation="Idle"
	$AnimatedSprite.play()


func _physics_process(delta: float) -> void:
		
	
	if $AnimatedSprite.animation!="Die":
		bodies=$DangerZone.get_overlapping_bodies()
		for body in bodies:
			if body.name=="Adam":
				body.corruption+=0.5
				body.HP-=0.2
		
		state_check()
		perform_state()
	
		bodies=$HitBox.get_overlapping_bodies()
		for body in bodies:
			if body.name=="Adam":
				if !body.knockback:
					body.hit(self,damage)
					
		
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
		$AnimatedSprite.material.set_shader_param("flash_modifier",1)
		$KnockbackTimer.start()
		health-=dmg
		$HurtSound.play()
		knockback=true
		if health<=0:
			Globals.enemies_killed+=1
			$HitBox/CollisionShape2D.set_deferred("disabled",true)
			$AnimatedSprite.animation="Die"
			$DieSound.play()
			velocity.x=0
		
			
func flip():
	if velocity.x<0:
		$AnimatedSprite.flip_h=true
		$CollisionShape2D.position.x=-1
		$WallCast.position.x=-16
	elif velocity.x>0:
		$AnimatedSprite.flip_h=false
		$CollisionShape2D.position.x=1
		$WallCast.position.x=16


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


func _on_AttackCooldown_timeout():
	if $VisibilityNotifier2D.is_on_screen():
		var proj_instance=projectile.instance()
		proj_instance.get_node("Sprite").modulate=Color(1,0,0,1)
		proj_instance.global_position=Vector2(global_position.x,global_position.y-14)
		if player.global_position>global_position:
			proj_instance.velocity=Vector2(2,0)
		elif player.global_position<global_position:
			proj_instance.velocity=Vector2(-2,0)
		get_parent().add_child(proj_instance)
		$Shoot.play()


func leave_pickups():
	if random.randi_range(1,2)==1:
		pickup=seal_scene.instance()
	else:
		pickup=hp_scene.instance()
	pickup.global_position=Vector2(global_position.x,global_position.y)
	get_parent().get_parent().add_child(pickup)

