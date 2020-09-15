extends RigidBody2D

var explosion_scene = preload("res://scenes/explosion.tscn")

signal destroyed()

var target_position = null

var previous_position = null
var crossed_at_y = null
var crossed_at_x = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_position(pos):
	previous_position = pos
	position = pos

func set_position(pos):
	previous_position = position
	position = pos

func _process(_delta):
	
#	position - previous_position
	var min_x = min(previous_position.x, position.x)
	var max_x = max(previous_position.x, position.x)
	
	if target_position.x >= min_x and target_position.x <= max_x:
		print(str("crossed target x 0 at ball y: ", position.y))
		crossed_at_y = position.y
	
	var min_y = min(previous_position.y, position.y)
	var max_y = max(previous_position.y, position.y)
	
	if target_position.y >= min_y and target_position.y <= max_y:
		print(str("crossed target y 0 at ball x: ", position.x))
		crossed_at_x = position.x
	
	
#	target_position between position and previous_position
#
#	crossed_at_y hight when crossed position x of taget
#	crossed_at_x distance when crossed position y of target
	
	previous_position = position
	
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

	
