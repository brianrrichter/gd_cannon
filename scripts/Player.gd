extends Area2D

signal destroyed()



var ball_scene = preload("res://scenes/Ball.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

var player_name = 'player'

var pointing_angle = 90.0
var velocity = 200
onready var cannon = $Cannon
var direction = -1
var type = Globals.player_type.HUMAN


# Called when the node enters the scene tree for the first time.
func _ready():
	$currentPlayerIndication.hide()
	pass # Replace with function body.

func set_current_player(current):
	if current:
		$currentPlayerIndication.show()
	else:
		$currentPlayerIndication.hide()

func set_pointing_angle(angle):
	pointing_angle = angle
	rotate_deg()

func rotate_deg():
	cannon.rotation_degrees = pointing_angle -90

func set_direction(dir):
	direction = dir
	cannon.scale.x = direction

func set_player_name(name):
	player_name = name
	$nameLabel.text = player_name

#func _process(_delta):
#	cannon.scale.x = direction

func cpu_update_aim():
	velocity = max((velocity + 50) % Globals.MAX_VELOCITY, Globals.MIN_VELOCITY)

func shoot():
	var resp = []
	var stage_node = get_parent()
	var ball_instance = ball_scene.instance()
#	ball_instance.add_collision_exception_with(self) ... only for body

#	if the ball initial position is inside parent's collisionShape
#	ball_instance.add_to_group("just_fired")

	ball_instance.position = $Cannon/ball_spawn.global_position

	var angle = pointing_angle

	var rad_ang = (angle -90) * PI / 180

	var dir = Vector2(cos(rad_ang), sin(rad_ang)) * direction


#	ball_instance.set_linear_velocity(dir * velocity)
	
	ball_instance.apply_impulse(Vector2(), dir * velocity)
	
	stage_node.add_child(ball_instance)
	resp.append(ball_instance)
	
	$ShotAudioStreamPlayer.play()
	
	return resp





func _on_Player_body_entered(body):
	if not body.is_in_group("just_fired"):
		
		body.destroy()
		
		queue_free()
		var explosion_instance = explosion_scene.instance()
		explosion_instance.position = position
		get_parent().add_child(explosion_instance)

		emit_signal("destroyed")


func _on_Player_body_exited(body):
	if body.is_in_group("just_fired"):
		body.remove_from_group("just_fired")
	pass # Replace with function body.
