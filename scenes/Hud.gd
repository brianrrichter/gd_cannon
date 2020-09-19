extends CanvasLayer


func show_message(text):
	$Message.text = text
	$AnimationPlayer.play("show_message")

