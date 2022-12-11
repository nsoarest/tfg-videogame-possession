extends Control

var rng=RandomNumberGenerator.new()
var treasure_info="Be careful, you can get anything from this chest."
var fireballs_info="Adam gains the ranged ability of throwing a demonic fireball but the corruption increases."
var holy_water_info="Adam’s corruption bar fills 50% slower but Adam takes twice damage (as it burns him because of being possessed)."
var current_upgrade=null
var treasure_upgrades=["PRAYSCROLL","JUMPSCARE","TRAPCHEST","HOLYSHIELD"]
var treasure_upgrade_info=["Start next level with a shield (that takes 2 hits for the enemy to break, before you take damage).",
						   "Start next level with the corruption bar filled at 25%.",
						   "Start next level with 25% less health.","With Holy shield, when you crouch, you take no damage."]

func _ready():
	rng.randomize()
	if Globals.upgrade1_equipped:
		Globals.upgrade1=null
		Globals.upgrade1_equipped=false


func _on_HolyWater_pressed():
	$InfoLabel.bbcode_text=holy_water_info
	current_upgrade="HOLYWATER"
		

func _on_Fireball_pressed():
	$InfoLabel.bbcode_text=fireballs_info
	current_upgrade="FIREBALLS"

func _process(delta):
	if current_upgrade!=null:
		$SelectButton.disabled=false
	if Globals.upgrade1_equipped:
		$SelectButton.disabled=true
	
	
func _on_SelectButton_pressed():
	if !Globals.upgrade1_equipped:
		if current_upgrade!="TREASURECHEST":
			Globals.upgrade1=current_upgrade
			Globals.upgrade1_equipped=true
			change_scene()
		else:
			var random_upgrade=rng.randi_range(0,3)
			Globals.upgrade1=treasure_upgrades[random_upgrade]
			Globals.upgrade1_equipped=true
			$Popup/RichTextLabel.bbcode_text="[center]"+treasure_upgrade_info[random_upgrade]+"[/center]"
			$Popup/RichTextLabel2.bbcode_text="[center]"+treasure_upgrades[random_upgrade]+"[/center]"
			$Popup.popup()
		


func _on_TreasureChest_pressed():
	$InfoLabel.bbcode_text=treasure_info
	current_upgrade="TREASURECHEST"


func _on_Popup_popup_hide():
	change_scene()
	
	
func change_scene():
		if Globals.current_level==2:
			get_tree().change_scene("res://Src/Level2.tscn")	
		elif Globals.current_level==3:
			get_tree().change_scene("res://Src/BossStory.tscn")
	
