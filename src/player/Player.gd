extends CharacterBody3D
class_name Player

# Character
@export var c : Resource;

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
var _shoot : bool = false;
var _skill : bool = false;

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var _shoot_func := Callable(self, "_dummy_skill");
var _skill_func := Callable(self, "_dummy_skill");

# Nodes
@onready var camera   := $CameraOrbit;
@onready var camera3d := $CameraOrbit/Camera3D;
@onready var mesh_i   := $Mesh;
@onready var collider := $Collider;
@onready var syncro   := $MultiplayerSynchronizer;

func _dummy_skill(_p: Player) -> void:
    pass

func _reload_vars() -> void:
    # NOTE: this does not work
    # if not c is BaseCharacter:
    #     printerr("ERROR: Invalid character provided");
    #     return;

    camera.position.y = c.eye_height;

    mesh_i.mesh = c.model_player;

    collider.shape.height = c.height;
    collider.position.y = c.height/2;

    _shoot_func = Callable(c.skills_object, c.function_shoot);
    _skill_func = Callable(c.skills_object, c.function_skill);

func _input(e: InputEvent) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    if not GlobalVariables.paused and e is InputEventMouseMotion:
        _mouse_delta = e.relative;

func _enter_tree() -> void:
    $MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)));

func _ready() -> void:
    print("Player.gd:", str(name), " ", GlobalVariables.camera_set);

    if not GlobalVariables.camera_set and syncro.is_multiplayer_authority():
        camera3d.current = true;
        GlobalVariables.camera_set = true;
    else:
        camera3d.current = false;

    if syncro.is_multiplayer_authority():
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
        _shoot = Input.is_action_just_pressed("shoot", false);
        _skill = Input.is_action_just_pressed("skill", false);

    var rot = _mouse_delta * dt * cam_look_sensitivity;

    camera.rotation.x = clamp(
        camera.rotation.x + rot.y,
        -cam_min_angle,
        cam_max_angle
    );
    rotation.y -= rot.x;
    _mouse_delta = Vector2();

    # Crouch logic
    var eye_height = c.eye_height_crouch if _crouch else c.eye_height;
    camera.position.y = move_toward(camera.position.y, eye_height, c.crouch_speed);

    var target_height = c.height_crouch if _crouch else c.height;
    var cur_height = move_toward(collider.shape.height, target_height, c.crouch_speed);
    collider.shape.height = cur_height;
    collider.position.y = cur_height/2;

    # Skill logic
    if _shoot: _shoot_func.call(self);
    if _skill: _skill_func.call(self);

func _physics_process(dt: float) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    if not is_on_floor():
        velocity.y -= _gravity * dt;

    if _jump and is_on_floor():
        velocity.y += c.jump_velocity;

    var dir = (transform.basis * Vector3(_move_vector.x, 0, _move_vector.y)).normalized();

    var speed = c.speed_crouch if _crouch \
           else c.speed_sprint if _sprint \
           else c.speed;
    if dir:
        velocity.x = -dir.x * speed;
        velocity.z = -dir.z * speed;
    else:
        velocity.x = move_toward(velocity.x, 0, speed);
        velocity.z = move_toward(velocity.z, 0, speed);

    move_and_slide();
