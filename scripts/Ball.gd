extends RigidBody2D

var explosion_scene = preload("res://scenes/explosion.tscn")

signal destroyed()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if position.y > 700:
		destroy()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Ball_body_entered(_body):
	destroy()

func destroy():
	emit_signal("destroyed")
	queue_free()
	var explosion_instance = explosion_scene.instance()
	explosion_instance.position = position
	get_parent().add_child(explosion_instance)
	get_node("../ExplosionAudioStreamPlayer").play()
#	get_parent().get/ExplosionAudioStreamPlayer.play()

	
