extends Area2D

export var velocity=2
export var health=100
export var damage=25
export var attack_cooldown=5
export var proj_speed=3
export var vertical=false
var is_dead=false
var random=RandomNumberGenerator.new()
var seal_scene=preload("res://Src/Seal.tscn")
var hp_scene=preload("res://Src/HealthPickup.tscn")

var type="FlyingEnemy"
onready var path_follow=get_parent()
onready var player=get_parent().get_parent().get_parent().get_node("Adam")
var projectile=preload("res://Src/EnemyProjectile.tscn")


func _ready():
	random.randomize()
	$AttackCooldown.wait_time=attack_cooldown
	if vertical:
		$AnimatedSprite.flip_h=true


func _process(delta):
	path_follow.offset+=velocity
	if path_follow.unit_offset==0 or path_follow.unit_offset==1:
		velocity=-velocity
		if !vertical:
			$AnimatedSprite.flip_h=true if velocity<0 else false
		else:
			$AnimatedSprite.flip_h=true if global_position.x-player.global_position.x>0 else false
	if health<=0 and $KnockbackTimer.is_stopped():
		if !is_dead:
			is_dead=true
			leave_pickups()
			$CollisionShape2D.set_deferred("disabled",true)
			velocity=0
			$DieSound.play()
			$AttackCooldown.stop()
		
		
	

func hit(body,dmg,knock):
	if $KnockbackTimer.is_stopped():
		$KnockbackTimer.start()
		health-=dmg
		$HurtSound.play()
		$AnimatedSprite.material.set_shader_param("flash_modifier",1)
		if health<=0:
			Globals.enemies_killed+=1

	
func _on_KnockbackTimer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier",0)



func _on_FlyingEnemy_area_entered(area):
	if area.name!="SlashArea":
		var parent=area.get_parent()
		if parent.name=="Adam":
			if !parent.is_dead:
				parent.hit(self,damage)




func _on_AttackCooldown_timeout():
	#Attack
	if $VisibilityNotifier2D.is_on_screen():
		var proj_instance=projectile.instance()
		proj_instance.global_position=global_position
		proj_instance.speed=proj_speed
		get_parent().get_parent().get_parent().add_child(proj_instance)
		$Shoot.play()
	
	
func leave_pickups():
	if random.randi_range(1,12)==4:
		var seal_inst=seal_scene.instance()
		seal_inst.global_position=global_position
		get_parent().get_parent().get_parent().add_child(seal_inst)
	elif random.randi_range(1,15)==4:
		var hp_inst=hp_scene.instance()
		hp_inst.global_position=global_position
		get_parent().get_parent().get_parent().add_child(hp_inst)
			
			
			
func _on_DieSound_finished():
	queue_free()


