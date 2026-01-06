extends Node3D

@onready var cameras: Array[Camera3D] = []

var current_camera_index := 0

func _ready():

	_find_cameras(self)
	
	if cameras.size() == 0:
		push_error("هیچ Camera3D پیدا نشد!")
		return
	
	for cam in cameras:
		cam.current = false
	
	_set_camera(0)
	


func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_0: _set_camera(0)
			KEY_1: _set_camera(1)
			KEY_2: _set_camera(2)
			KEY_3: _set_camera(3)
			KEY_4: _set_camera(4)
			KEY_5: _set_camera(5)
			KEY_6: _set_camera(6)
			KEY_7: _set_camera(7)
			KEY_8: _set_camera(8)
			KEY_9: _set_camera(9)

func _set_camera(index: int):
	if index < 0 or index >= cameras.size():
		return
	
	for cam in cameras:
		cam.current = false
	
	cameras[index].current = true
	current_camera_index = index
	


func _find_cameras(node: Node):
	for child in node.get_children():
		if child is Camera3D:
			cameras.append(child)
		elif child.get_child_count() > 0:
			_find_cameras(child)
