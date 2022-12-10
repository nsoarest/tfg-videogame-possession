extends Area2D

var mouse_hover=false
signal player_won
signal player_lost


func _on_ClickableSkulls_mouse_entered():
	mouse_hover=true


func _on_ClickableSkulls_mouse_exited():
	mouse_hover=false

	
func _process(delta):
	if mouse_hover:
		if Input.is_action_just_pressed("LMB"):
			win()
			


func _on_ClickTime_timeout():
	loose()

	
func loose():
	emit_signal("player_lost")
	queue_free()
	
	
func win():
	emit_signal("player_won")
	queue_free()
