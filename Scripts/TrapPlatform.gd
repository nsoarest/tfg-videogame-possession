extends Area2D



func _on_TrapPlatform_body_entered(body):
	if body.name=="Adam":
		$DestroyTimer.start()
		$AnimationPlayer.play("Break")


func _on_DestroyTimer_timeout():
	queue_free()
