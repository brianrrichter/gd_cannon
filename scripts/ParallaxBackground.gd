extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var parallax_clouds = $ParallaxLayer
var wind_velocity = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parallax_clouds.motion_offset.x += wind_velocity * delta

func set_wind_velocity(var vel):
	wind_velocity = vel * 1
