extends PathFollow3D

@export var speed = 0.5
#
func _process(delta):
	progress += delta * speed
