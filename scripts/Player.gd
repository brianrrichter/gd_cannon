extends Area2D

signal destroyed()



var ball_scene = preload("res://scenes/Ball.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

var player_name = 'player'

var angle_max = 180
var angle_min = -90

var pointing_angle = 0.0
var velocity = 200
onready var cannon = $Cannon
var direction = -1
var type = Globals.player_type.HUMAN

var min_angle_increment = 5
var min_velocity_increment = 25
var base_angle_increment = 15
var base_velocity_increment = 200
var prev_increase_decrease = null
var prev_burst_distance = null

#feed information for non human player
var enemy_position = Vector2(0, 0)
var projectile_burst_position = null #Vector2(0, 0)
var projectile_crossed_at_y = null
var projectile_crossed_at_x = null

var angle_inverted_due_continuously_incrementing = false


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
	pointing_angle = max(min(angle, angle_max), angle_min)
	rotate_deg()

func rotate_deg():
#	cannon.rotation_degrees = pointing_angle -90
	cannon.rotation_degrees = pointing_angle * direction * -1

func set_direction(dir):
	direction = dir
	cannon.scale.x = direction

func set_player_name(name):
	player_name = name
	$nameLabel.text = player_name

#func _process(_delta):
#	cannon.scale.x = direction

func cpu_update_aim():
	# position of the enemy
	# position where the ball exploded
	# burst before or after the enemy
	
#	projectile_crossed_at_x <<<<<<<<<<<<<<<<<<<<<<
	
	var increase_decrease = 0
	var burst_distance = null
	if projectile_burst_position != null:
		burst_distance = abs(enemy_position.x - projectile_burst_position.x)
		
#		if projectile_crossed_at_y == null or projectile_crossed_at_y < 0:
		if abs(position.x - enemy_position.x) > abs(position.x - projectile_burst_position.x):
			increase_decrease = 1
		else:
			increase_decrease = -1
#		if enemy_position.x < position.x:
#			if projectile_burst_position.x < enemy_position.x :
#				increase_decrease = -1
#			else:
#				increase_decrease = 1
#		else:
#			if projectile_burst_position.x < enemy_position.x :
#				increase_decrease = 1
#			else:
#				increase_decrease = -1
	
	
	print(str(">>> prev_burst_distance: ", prev_burst_distance, ", burst_distance: ", burst_distance))
	
	
	if prev_increase_decrease != null and prev_increase_decrease != increase_decrease: #on change fire further or closer, reduces increments
		
		angle_inverted_due_continuously_incrementing = false
		
		base_velocity_increment = base_velocity_increment / 2
		base_angle_increment = base_angle_increment * .5
	elif prev_increase_decrease == increase_decrease and increase_decrease == 1 and prev_burst_distance != null and prev_burst_distance < burst_distance:
		#if it is still increasing the power and the last burst was closer to the target, 
		
		if !angle_inverted_due_continuously_incrementing:
			angle_inverted_due_continuously_incrementing = true #for inverting only once
			
			#invert the angle, so it'll increase in the opposite of velocity, making the ball go further
			base_angle_increment = base_angle_increment * -1
	
	prev_increase_decrease = increase_decrease
	prev_burst_distance = burst_distance if prev_burst_distance == null else min(prev_burst_distance, burst_distance)
	
	var velocity_increment = base_velocity_increment * increase_decrease
	var angle_increment = base_angle_increment * increase_decrease
	
	velocity = max(min((velocity + velocity_increment), Globals.MAX_VELOCITY), Globals.MIN_VELOCITY)
	
#	pointing_angle = pointing_angle + 10
	set_pointing_angle(pointing_angle + angle_increment)

func shoot():
	var resp = []
	var stage_node = get_parent()
	var ball_instance = ball_scene.instance()
#	ball_instance.add_collision_exception_with(self) ... only for body

#	if the ball initial position is inside parent's collisionShape
#	ball_instance.add_to_group("just_fired")

	ball_instance.init_position($Cannon/ball_spawn.global_position)
	ball_instance.target_position = enemy_position

	ball_instance.connect("destroyed", self, "projectile_destroyed", [ball_instance])
	
	var angle = pointing_angle

	var rad_ang = (angle) * PI / 180

	var dir = Vector2()
	if direction == 1:
		dir = Vector2(cos(rad_ang), sin(rad_ang) * -1)
	else:
		dir = Vector2(cos(rad_ang), sin(rad_ang)) * direction
		
	
	print(str(" >>>>> shoot direction: ", dir))
#	ball_instance.set_linear_velocity(dir * velocity)
	
	$Cannon/SmokeAnimationPlayer.play("shoot")
	
	ball_instance.apply_impulse(Vector2(), dir * velocity)
	
	stage_node.add_child(ball_instance)
	resp.append(ball_instance)
	
	$ShotAudioStreamPlayer.play()
	
	return resp


func projectile_destroyed(projectile):
	projectile_burst_position = projectile.position
	projectile_crossed_at_y = projectile.crossed_at_y
	projectile_crossed_at_x = projectile.crossed_at_x
	
	print(str(">>>> ", player_name, " projectile burst position: ", projectile_burst_position));



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
