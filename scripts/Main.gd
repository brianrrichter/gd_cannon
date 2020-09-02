extends Node2D

enum {WELCOME, INITIALIZING, WAITING_INPUT, WAITING_CPU, RESOLVING, CHECKING_WINNER, OVER}

var game_state = WAITING_INPUT

#var ball_scene = preload("res://Ball.tscn")
var player_scene = preload("res://scenes/Player.tscn")

#var velocity = 100
var wind_velocity = 0

#var angle = 90.0
#onready var player1 = null
#onready var player2 = null
onready var players = []
onready var currentPlayer = 0

var resolvable_items = []


func _ready():
	game_state = WELCOME
	$instructionsLabel.show()
	$gameOverLabel.hide()
#	next_round()
	$Floor.generate()
	
	$BackgroundAudioStreamPlayer.play()
	
	


	

func next_round():
	$gameOverLabel.hide()
	
	$Floor.generate()
	
	while not players.empty():
		players.pop_front().queue_free()
	
	while not resolvable_items.empty():
		var i = resolvable_items.pop_front()
		if i != null:
			i.queue_free()
	
	
	wind_velocity = randi() % 60 - 30
	
	currentPlayer = randi() % 2
	
	var rand_player1_type = randi() % 2
	var rand_player2_type = (rand_player1_type + 1) % 2 #human vs cpu, choose the type wich is not the player1 type
	
	var player1 = create_new_player("Player" if rand_player1_type == Globals.player_type.HUMAN else "CPU", $Floor.getSpotPosition(0), rand_player1_type) #Globals.player_type.HUMAN)
	var player2 = create_new_player("Player" if rand_player2_type == Globals.player_type.HUMAN else "CPU", $Floor.getSpotPosition(1), rand_player2_type) #Globals.player_type.CPU)

	if player1.position.x < player2.position.x:
		player1.set_direction(1)
		player2.set_direction(-1)
	else:
		player1.set_direction(-1)
		player2.set_direction(1)
	
	game_state = WAITING_INPUT
	
	var curr = get_current_player()
	if curr != null:
		curr.set_current_player(true)
		if curr.type == Globals.player_type.CPU:
			game_state = WAITING_CPU

func create_new_player(name, pos, type):
	var player_instance = player_scene.instance()
	player_instance.set_player_name(name)
	player_instance.position = pos
	player_instance.type = type
	add_child(player_instance)
	players.append(player_instance)

	player_instance.connect("destroyed", self, "on_player_destroyed", [player_instance])

	return player_instance

func on_player_destroyed(player):
	players.erase(player)
#	set_process_input(false)
#	get_tree().paused = true

func _input(event):

	if event is InputEventKey and event.scancode == KEY_Q and event.pressed == false:
		get_tree().quit()
	
	if event is InputEventKey and event.scancode == KEY_F1 and event.pressed == false:
		$instructionsLabel.visible = !$instructionsLabel.visible
	
	if event is InputEventKey and event.scancode == KEY_F3 and event.pressed == false:
		var muted = !AudioServer.is_bus_mute(0)
		$SoundOnOffAnimatedSprite.frame = 1 if muted else 0
		AudioServer.set_bus_mute(0, muted)
	
	if event is InputEventKey and event.scancode == KEY_T and event.pressed == false:
		$Floor.test()

	if game_state != WELCOME and event is InputEventKey and event.scancode == KEY_R and event.pressed == false:
#		get_tree().reload_current_scene()
		next_round()

	if game_state == WELCOME:
		if event is InputEventKey and event.scancode == KEY_ENTER and event.pressed == false:
			$instructionsLabel.hide()
			game_state = INITIALIZING
	elif game_state == WAITING_INPUT:
#		var curr = get_current_player()
#		if curr != null and curr.type == Globals.player_type.CPU:
#			var items = curr.shoot()
#			for i in items:
#				resolvable_items.append(i)
#				i.connect("destroyed", $Floor, "projectile_destroyed", [i])
#
#			game_state = RESOLVING
		if event is InputEventKey and event.scancode == KEY_SPACE and event.pressed == false:
			var curr = get_current_player()
			if curr != null:
				var items = curr.shoot()
				for i in items:
					resolvable_items.append(i)
					i.connect("destroyed", $Floor, "projectile_destroyed", [i])
			else:
				print("null player")
	
#			velocity = 100
			
			
			
			game_state = RESOLVING

func advance_next_player():
	var curr = get_current_player()
	curr.set_current_player(false)
	currentPlayer = ((currentPlayer + 1) % players.size()) if not players.empty() else 0
	
	if get_current_player() != null:
		get_current_player().set_current_player(true)

func get_current_player():
	if players.size() <= currentPlayer:
		return null
	var curr = players[currentPlayer]
	if is_instance_valid(curr):
		return curr
	return null

func _process(delta):
	
	if game_state == INITIALIZING:
		next_round()
		
	elif game_state == CHECKING_WINNER:
		if players.size() <= 1:
			
			$gameOverLabel.text = (str(players.front().name, " WON!")) if not players.empty() else str("tie")
			$gameOverLabel.show()
			game_state = OVER
		else:
			advance_next_player()
			var curr = get_current_player()
			if curr != null and curr.type == Globals.player_type.CPU:
				game_state = WAITING_CPU
			else:
				game_state = WAITING_INPUT
	elif game_state == OVER:
		
		pass;
	elif game_state == WAITING_CPU:
		var curr = get_current_player()
		if curr != null:
#			curr.velocity = curr.velocity + 50
			curr.cpu_update_aim()
			var items = curr.shoot()
			for i in items:
				resolvable_items.append(i)
				i.connect("destroyed", $Floor, "projectile_destroyed", [i])
		else:
			print("null player")
		game_state = RESOLVING
		
	elif game_state == WAITING_INPUT:
		var curr = get_current_player()
		
		if curr == null:
			print("current player is null")
			print(str("players => ", players.size()))
			print(str("current_player => ", currentPlayer))
			return
		var angle = curr.pointing_angle
		if Input.is_key_pressed(KEY_K):
			curr.velocity = curr.velocity + round(50 * delta)
			if curr.velocity > Globals.MAX_VELOCITY:
				curr.velocity = Globals.MAX_VELOCITY
		if Input.is_key_pressed(KEY_J):
			curr.velocity = curr.velocity - round(50 * delta)
			if curr.velocity < Globals.MIN_VELOCITY:
				curr.velocity = Globals.MIN_VELOCITY
		if Input.is_key_pressed(KEY_L) and angle <= 360:
			angle = angle + (100 * delta)
		if Input.is_key_pressed(KEY_H) and angle > 0:
			angle = angle - (100 * delta)
		
		curr.set_pointing_angle(angle)
#		curr.velocity = velocity
		$Label.text = str("power: ", curr.velocity, "\nangle: ", angle, "\nwind: ", wind_velocity)
	
	elif game_state == RESOLVING:
		if not resolvable_items.empty():
			if not is_instance_valid(resolvable_items[0]):
				print("not valid instance")
				resolvable_items.remove(0)
			elif wind_velocity != 0:#wind
				resolvable_items[0].add_force(Vector2.ZERO, Vector2(wind_velocity, 0) * delta)

#		for i in resolvable_items:
#			if not is_instance_valid(i):
#				resolvable_items.erase(i)
		if resolvable_items.size() == 0:
			game_state = CHECKING_WINNER
