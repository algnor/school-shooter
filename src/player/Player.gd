extends CharacterBody3D

@export_group("Character Properties", "p_")
@export var p_speed : float = 5.0;
@export var p_sprint_speed : float = 15.0;
@export var p_jump_velocity : float = 5.0;
@export var p_crouch_speed : float = 0.1;

@export var p_height : float = 2.0;
@export var p_height_crouch : float = 2.0;
@export var p_eye_height : float = 1.8;
@export var p_eye_height_crouch : float = 1.2;

@export_group("Camera Properties", "cam_")
@export_range(0, 90, 0.1, "radians") var cam_look_sensitivity : float = PI/12;
@export_range(0, 90, 0.1, "radians") var cam_min_angle : float = PI/2;
@export_range(0, 90, 0.1, "radians") var cam_max_angle : float = PI/2;

# Inputs
var _mouse_delta : Vector2 = Vector2();
var _move_vector : Vector2 = Vector2();
var _jump : bool = false;
var _sprint : bool = false;
var _crouch : bool = false;

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

# Nodes
@onready var camera   := $CameraOrbit;
@onready var camera3d := $CameraOrbit/Camera3D;
@onready var mesh_i   := $Mesh;
@onready var collider := $Collider;
@onready var syncro   := $MultiplayerSynchronizer;

func _reload_vars() -> void:
    camera.position.y = p_eye_height;

    mesh_i.mesh.height = p_height;
    mesh_i.position.y = p_height/2;

    collider.shape.height = p_height;
    collider.position.y = p_height/2;

func _input(e: InputEvent) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    if not GlobalVariables.paused and e is InputEventMouseMotion:
        _mouse_delta = e.relative;

func _enter_tree() -> void:
    $MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)));

func _ready() -> void:
    print("Player.gd:", str(name));
    camera3d.current = syncro.is_multiplayer_authority();

    _reload_vars();

func _process(dt: float) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    # Input handling
    if not GlobalVariables.paused:
        _move_vector = Input.get_vector("move_left", "move_right",
                                        "move_forward", "move_backward");
        _jump = Input.is_action_pressed("move_jump", false);
        _sprint = Input.is_action_pressed("move_sprint", false);
        _crouch = Input.is_action_pressed("move_crouch", false);

    var rot = _mouse_delta * dt * cam_look_sensitivity;

    camera.rotation.x = clamp(
        camera.rotation.x + rot.y,
        -cam_min_angle,
        cam_max_angle
    );
    rotation.y -= rot.x;
    _mouse_delta = Vector2();

    var eye_height = p_eye_height_crouch if _crouch else p_eye_height;
    camera.position.y = move_toward(camera.position.y, eye_height, p_crouch_speed);
    # TODO: update hitbox when crouched, p_crouch_height

func _physics_process(dt: float) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    if not is_on_floor():
        velocity.y -= _gravity * dt;

    if _jump and is_on_floor():
        velocity.y += p_jump_velocity;

    var dir = (transform.basis * Vector3(_move_vector.x, 0, _move_vector.y)).normalized();

    var speed = p_sprint_speed if _sprint else p_speed;
    if dir:
        velocity.x = -dir.x * speed;
        velocity.z = -dir.z * speed;
    else:
        velocity.x = move_toward(velocity.x, 0, speed);
        velocity.z = move_toward(velocity.z, 0, speed);

    move_and_slide();
