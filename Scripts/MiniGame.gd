extends Node2D

var skull=preload("res://Src/ClickableSkulls.tscn")
var skull_count=0
var rng=RandomNumberGenerator.new()
var HP=100

func _ready():
	rng.randomize()


func _on_StartTimer_timeout():
	$SkullTimer.start()


func _process(delta):
	$HP.value=HP
	if HP<=0:
		$LoseLabel.visible=true
		$LoseButton2.visible=true
		$LoseButton.visible=true
		$SkullTimer.stop()	


func _on_SkullTimer_timeout():
	if skull_count<5:
		var skull_inst=skull.instance()
		skull_inst.global_position=Vector2(rng.randi_range(-112,128),rng.randi_range(16,112))
		skull_inst.connect("player_lost",self,"damage_adam")
		skull_inst.connect("player_won",self,"damage_azazel")
		get_parent().add_child(skull_inst)
		skull_count+=1
	elif skull_count==5:
		win()


func damage_adam():
	HP-=34
	$KnockbackTimer.start()	
	$Adam.material.set_shader_param("flash_modifier",1)
	$Adam.material.set_shader_param("flash_color",Color(1,1,1,1))

	
func damage_azazel():
	$KnockbackTimer.start()	
	$Adam.material.set_shader_param("flash_modifier",1)
	$Adam.material.set_shader_param("flash_color",Color(0.55,0.02,0.02,1))

	
func _on_KnockbackTimer_timeout():
	$Adam.material.set_shader_param("flash_modifier",0)


func _on_LoseButton_pressed():
	Globals.hp_modifier+=0.1
	Globals.hp_modifier=clamp(Globals.hp_modifier,Globals.min_hp_modifier,Globals.max_hp_modifier)
	Globals.damage_modifier+=0.5
	Globals.damage_modifier=clamp(Globals.damage_modifier,Globals.min_damage_modifier,Globals.max_damage_modifier)
	Globals.current_level=1
	if $LoseLabel.text!="You Have Escaped":
		Globals.upgrade1=null
		Globals.upgrade1_equipped=false
		Globals.boss_hp=100
	get_tree().change_scene("res://Src/Level1.tscn")


func _on_LoseButton2_pressed():
	get_tree().change_scene("res://Src/Menu.tscn")


func win():
	$SkullTimer.stop()
	$LoseLabel.text="You Have Escaped"
	$LoseButton.text="Continue"
	$LoseLabel.visible=true
	$LoseButton2.visible=true
	$LoseButton.visible=true
	
