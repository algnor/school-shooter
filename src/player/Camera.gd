extends Node3D

@export var look_sensitivity : float = 15.0;
@export var min_angle : float = -20.0;
@export var max_angle : float =  75.0;

var mouse_delta : Vector2 = Vector2();
@onready var player = get_parent();

func _input(e):
    if e is InputEventMouseMotion:
        mouse_delta = e.relative;

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _process(dt):
    var rot = Vector3(mouse_delta.y, mouse_delta.x, 0) * dt * deg_to_rad(look_sensitivity);

    rotation.x = clamp(rotation.x + rot.x, deg_to_rad(min_angle), deg_to_rad(max_angle));
    player.rotation.y -= rot.y;

    mouse_delta = Vector2();
