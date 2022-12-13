extends CharacterBody3D

@export_group("Character Properties", "p_")
@export var p_speed : float = 5.0;
@export var p_jump_vel : float = 5.0;

@export_group("Camera Properties", "cam_")
@export var cam_look_sensitivity : float = 15.0;
@export var cam_min_angle : float = -90;
@export var cam_max_angle : float =  90;

var _mouse_delta : Vector2 = Vector2();
var _move_vector : Vector2 = Vector2();
var _jump : bool = false;
var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
@onready var camera = $CameraOrbit;

func _input(e: InputEvent) -> void:
    if e is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
    elif e.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED \
        and e is InputEventMouseMotion:
        _mouse_delta = e.relative;

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _process(dt: float) -> void:
    var rot = _mouse_delta * dt * deg_to_rad(cam_look_sensitivity);

    camera.rotation.x = clamp(
        camera.rotation.x + rot.y,
        deg_to_rad(cam_min_angle),
        deg_to_rad(cam_max_angle)
    )
    rotation.y -= rot.x;

    _mouse_delta = Vector2();

    # Input handling
    _move_vector = Input.get_vector("move_left", "move_right",
                                    "move_forward", "move_backward");
    _jump = Input.is_action_pressed("move_jump", false);

func _physics_process(dt: float) -> void:
    if not is_on_floor():
        velocity.y -= _gravity * dt;

    if _jump and is_on_floor():
        velocity.y += p_jump_vel;

    var dir = (transform.basis * Vector3(_move_vector.x, 0, _move_vector.y)).normalized();

    if dir:
        velocity.x = -dir.x * p_speed
        velocity.z = -dir.z * p_speed
    else:
        velocity.x = move_toward(velocity.x, 0, p_speed)
        velocity.z = move_toward(velocity.z, 0, p_speed)

    move_and_slide();
