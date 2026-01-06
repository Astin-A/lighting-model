extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Degrees per second
	pass
	
	
@export var rotation_speed: float = 10.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(deg_to_rad(rotation_speed * delta))
