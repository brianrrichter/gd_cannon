extends Node2D

const FLOOR_WIDTH = 950
const FLOOR_HEIGHT = 550
const FLOOR_MIN_X = 50

var texture = preload("res://images/floor_grass.png")
#onready var image = Image.new()
#onready var texture = ImageTexture.new()

var side_a_height
var side_b_height

# Called when the node enters the scene tree for the first time.
func _ready():
#	image.load("res://images/floor_grass.png")
#	texture.create_from_image(image)
	
	pass # Replace with function body.

#get the vector position for the player/spot
func getSpotPosition(index):
	
	var HEIGHT_OFFSET = -10
	
	if index == 0:
		return Vector2(FLOOR_MIN_X + FLOOR_WIDTH * .05, FLOOR_HEIGHT - side_a_height + HEIGHT_OFFSET);
	return Vector2(FLOOR_WIDTH - FLOOR_WIDTH * .05, FLOOR_HEIGHT - side_b_height + HEIGHT_OFFSET);

func test():
	hit_floor(Vector2(500, 250))

func projectile_destroyed(projectile):
	hit_floor(projectile.position)

func hit_floor(pos : Vector2):
	
	
	var collision_polygons = $StaticBody2D.get_children()
	
	for cp in collision_polygons:
		if !(cp is CollisionPolygon2D):
			continue
		
		var pol1 = cp.polygon #$StaticBody2D/CollisionPolygon2D.polygon
		
		var res = Geometry.clip_polygons_2d(pol1, create_destruction_polygon(pos))
		
		if res.empty():
			cp.queue_free()
			continue
		
		elif res.size() > 0:
#			$StaticBody2D/CollisionPolygon2D.polygon = res.pop_front()
			cp.polygon = res.pop_front()
#			if (cp.get_children().front() != null):
#				cp.get_children().front().queue_free()
			cp.get_children().front().polygon = cp.polygon
		
		if res.size() >= 1:
			print("more than one child polygon")
			for p in res:
				var collPol = CollisionPolygon2D.new()
				collPol.polygon = p
				$StaticBody2D.add_child(collPol)
				
				var ground = Polygon2D.new()
				ground.polygon = p
				ground.texture = texture
				collPol.add_child(ground)
				
	
	update()

func create_destruction_polygon(origin = Vector2(500, 250)):
	var res : PoolVector2Array
	var points_qtd = 20
	var radius = 50
	
	
	for i in range(points_qtd):
		res.append(origin + Vector2(radius, 0).rotated((2 * PI) / points_qtd * i))
	
	return res

func generate():
	#creating floor
	
	#remove children
	var collision_polygons = $StaticBody2D.get_children()
	for cp in collision_polygons:
		if !(cp is CollisionPolygon2D):
			continue
		$StaticBody2D.remove_child(cp);
	
	var collPol = CollisionPolygon2D.new()
	$StaticBody2D.add_child(collPol)
	
	side_a_height = randi() % (FLOOR_HEIGHT / 2) + 25 #50
	side_b_height = randi() % (FLOOR_HEIGHT / 2) + 25 #100
	
	var middle_height = randi() % (FLOOR_HEIGHT / 2) + 25 #100
	
	var curve = Curve2D.new()
	
	var array_of_line_points = []
	
	array_of_line_points.append(Vector2(FLOOR_MIN_X,FLOOR_HEIGHT - side_a_height))
	array_of_line_points.append(Vector2(FLOOR_MIN_X,FLOOR_HEIGHT))
	array_of_line_points.append(Vector2(FLOOR_WIDTH,FLOOR_HEIGHT))
	
	#left side platform
	array_of_line_points.append(Vector2(FLOOR_WIDTH,FLOOR_HEIGHT - side_b_height))
	array_of_line_points.append(Vector2(FLOOR_WIDTH - FLOOR_WIDTH * .1,FLOOR_HEIGHT - side_b_height))
	
	#middle slope
	array_of_line_points.append(Vector2(FLOOR_WIDTH - FLOOR_WIDTH / 2,FLOOR_HEIGHT - middle_height))
	
	#right side platform
	array_of_line_points.append(Vector2(FLOOR_MIN_X + FLOOR_WIDTH * .1,FLOOR_HEIGHT - side_a_height))
	
	var i = 0
	for point in array_of_line_points:
		if i < 4 or i > 6:
			curve.add_point(point, Vector2.ZERO, Vector2.ZERO)
		elif i == 4:
			curve.add_point(point, Vector2.ZERO, Vector2(-100, 0))
		elif i == 6:
			curve.add_point(point, Vector2(100, 0), Vector2.ZERO)
		else:#5
			curve.add_point(point, Vector2(100, 0), Vector2(-100, 0))
		
		i = i + 1
	
	collPol.polygon = curve.tessellate()
	
	var ground = null
	if is_instance_valid(collPol.get_children().front()):
		ground = collPol.get_children().front()
	else:
		ground = Polygon2D.new()
		ground.texture = texture
		collPol.add_child(ground)
	ground.polygon = collPol.polygon
	
	update()


#func _draw():
##	var color = Color(1.0, 1.0, 1.0)
#	var color = Color(0.2, 0.6, 0.2)
#	var colors = PoolColorArray([color])
#
#	var collision_polygons = $StaticBody2D.get_children()
#
#	for cp in collision_polygons:
#		if !(cp is CollisionPolygon2D):
#			continue
#
#		var pol1 = cp.polygon
#
#		draw_polygon(pol1, colors, pol1)
#
##		var pol2 = [Vector2(0, 0), Vector2(512, 0), Vector2(512, 128), Vector2(0, 128)]
##
##		draw_polygon(pol1, colors, pol1, texture, texture)
	
