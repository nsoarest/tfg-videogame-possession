extends CanvasLayer

onready var player=get_parent().get_node("Adam")
var holywater_texture=preload("res://Assets/HolyWater.png")
var treasure_texture=preload("res://Assets/TreasureChest.png")
var fireball_texture=preload("res://Assets/PlayerFireball.png")
var shield_texture=preload("res://Assets/Shield.png")
var holyshield_texture=preload("res://Assets/HolyShield.png")

func _ready():
	apply_upgrade1()


func _process(delta):
	$HP.value=player.HP
	$Corruption.value=player.corruption


func _on_Adam_player_dead():
	$LoseLabel.visible=true
	$LoseButton.visible=true
	$LoseButton2.visible=true


func _on_LoseButton_pressed():
	if Globals.current_level!=1:
		Globals.upgrade1_equipped=false
		Globals.upgrade1=null
	Globals.current_level=1
	get_tree().change_scene("res://Src/Level1.tscn")
	
	
func _on_LoseButton2_pressed():
	get_tree().change_scene("res://Src/Menu.tscn")


func apply_upgrade1():
	if Globals.upgrade1_equipped:
		if Globals.upgrade1=="HOLYWATER":
			$Upgrade1.texture=holywater_texture
			get_parent().get_node("Adam").has_holywater=true
		elif Globals.upgrade1=="FIREBALLS":
			$Upgrade1.texture=fireball_texture
			get_parent().get_node("Adam").can_fire=true
		else:
			$Upgrade1.texture=treasure_texture	
			if Globals.upgrade1=="TRAPCHEST":
				get_parent().get_node("Adam").HP=75
			elif Globals.upgrade1=="JUMPSCARE":
				get_parent().get_node("Adam").corruption=25
			elif Globals.upgrade1=="PRAYSCROLL":
				get_parent().get_node("Adam").shield=2
				$Upgrade1.texture=shield_texture
			elif Globals.upgrade1=="HOLYSHIELD":
				$Upgrade1.texture=holyshield_texture
				get_parent().get_node("Adam").holy_shield=true
			if Globals.upgrade1=="PRAYSCROLL" or Globals.upgrade1=="HOLYSHIELD":
				$Upgrade1.rect_position=Vector2(5,34)
	


