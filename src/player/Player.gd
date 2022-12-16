extends CharacterBody3D
class_name Player

# Character
@export var c : Resource;

@export_group("Camera Properties", "cam_")
@export_range(0, 90, 0.1, "radians") var cam_look_sensitivity : float = PI/12;
@export_range(0, 90, 0.1, "radians") var cam_min_angle : float = PI/2;
@export_range(0, 90, 0.1, "radians") var cam_max_angle : float = PI/2;

@export_group("Multiplayer (Do not touch)")
@export var health : int = 0 : set = _set_hp;
@export var ammo : int = 0 : set = _set_ammo;
@export var dead : bool = false;

# Inputs
var _mouse_delta : Vector2 = Vector2();
var _move_vector : Vector2 = Vector2();
var _jump : bool = false;
var _sprint : bool = false;
var _crouch : bool = false;
var _shoot : bool = false;
var _skill : bool = false;
var _reload : bool = false;

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var _shoot_func := Callable(self, "_dummy_skill");
var _skill_func := Callable(self, "_dummy_skill");
var _reload_func := Callable(self, "_dummy_skill");
var _can_shoot : bool = true;
var _can_skill : bool = true;
var _is_reloading : bool = false;

# HACK: Used for debugging, remove later
func _set_hp(val: int) -> void:
    if health != val:
        print("Player:", name, " modified HP ", health, "->", val);
    health = val;

func _set_ammo(val: int) -> void:
    if ammo != val:
        print("Player:", name, " modified ammo ", ammo, "->", val);
    ammo = val;

# Nodes
@onready var camera    := $CameraOrbit;
@onready var camera3d  := $CameraOrbit/Camera3D;
@onready var mesh_i    := $Mesh;
@onready var collider  := $Collider;
@onready var syncro    := $MultiplayerSynchronizer;
@onready var gun       := $CameraOrbit/Pistol;
@onready var ray       := $CameraOrbit/ShootRay;
@onready var gui       := get_node("/root/test_level/GUI");
@onready var stats     := gui.get_node("Stats");
@onready var death_scr := gui.get_node("DeathScreen");

# Timers
@onready var timer_shoot  := $Timers/Shoot;
@onready var timer_skill  := $Timers/Skill;
@onready var timer_reload := $Timers/Reload;

# Private methods
func _dummy_skill(_p: Player) -> void:
    pass

func _reset_timeout(type: int) -> void:
    match type:
        0: _can_shoot = true;
        1: _can_skill = true;
        2: _is_reloading = false; ammo = c.max_ammo;

func _reload_vars() -> void:
    print("Player:", name, " reload_vars");
    # NOTE: this does not work
    # if not c is BaseCharacter:
    #     printerr("ERROR: Invalid character provided");
    #     return;

    # Mesh & Collider
    camera.position.y = c.eye_height;
    # FIXME: player model does not work
    mesh_i.mesh = c.model_player;
    collider.shape.height = c.height;
    collider.position.y = c.height/2;

    # Skills
    _shoot_func = Callable(c.skills_object, c.function_shoot);
    _skill_func = Callable(c.skills_object, c.function_skill);
    _reload_func = Callable(c.skills_object, c.function_reload);

    # Stats
    health = c.max_health;
    ammo = c.max_ammo;

    # visible = true;
    dead = false;
    death_scr.visible = false;
    position = Vector3.ZERO;

# Public methods
func shoot(consume: bool = true):
    # TODO: shoot from weapon
    if consume: ammo -= 1;
    ray.force_raycast_update();
    if ray.is_colliding():
        print("hit: ", str(ray.get_collider().name));
        return ray.get_collider();

@rpc(any_peer, call_local)
func die():
    print("Player:", str(name), " died");
    dead = true;

func shoot_dmg(damage: int, consume: bool = true):
    var hit = shoot(consume);
    if hit is Player:
        # hit.take_damage(damage);
        hit.rpc("take_damage", damage);

@rpc(any_peer)
func take_damage(damage):
    health -= damage;
    print("Player:", name, " takes ", damage,
        " dmg (", health, "/", c.max_health, ")");
    if health <= 0:
        print("health <= 0");
        die();

# Lifecycle
func _input(e: InputEvent) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    if not GlobalVariables.paused and e is InputEventMouseMotion:
        _mouse_delta = e.relative;

func _enter_tree() -> void:
    $MultiplayerSynchronizer.set_multiplayer_authority(int(str(name)));

func _ready() -> void:
    print("Player.gd:", str(name), " ", syncro.is_multiplayer_authority());

    if not GlobalVariables.camera_set and syncro.is_multiplayer_authority():
        camera3d.current = true;
        GlobalVariables.camera_set = true;
    else:
        camera3d.current = false;

    if syncro.is_multiplayer_authority():
        GlobalVariables.current_player = self;
        _reload_vars();

func _process(dt: float) -> void:
    if not syncro.is_multiplayer_authority():
        return;

    # Input handling
    if not GlobalVariables.paused and not dead:
        _move_vector = Input.get_vector("move_left", "move_right",
                                        "move_forward", "move_backward");
        _jump = Input.is_action_pressed("move_jump", false);
        _sprint = Input.is_action_pressed("move_sprint", false);
        _crouch = Input.is_action_pressed("move_crouch", false);
        _shoot = Input.is_action_just_pressed("shoot", false);
        _skill = Input.is_action_just_pressed("skill", false);
        _reload = Input.is_action_just_pressed("reload", false);

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
    if _shoot and _can_shoot and ammo > 0 and not _is_reloading:
        _shoot_func.call(self);
        _can_shoot = false;
        timer_shoot.start(c.timeout_shoot);

    if _skill and _can_skill:
        _skill_func.call(self);
        _can_skill = false;
        timer_skill.start(c.timeout_skill);

    if _reload and not _is_reloading:
        _reload_func.call(self);
        _is_reloading = true;
        timer_reload.start(c.timeout_reload);

    # Update stats
    stats.update_health(health, c.max_health);
    stats.update_ammo(ammo, c.max_ammo);
    stats.update_skill(timer_skill.time_left, timer_skill.wait_time);

    if dead:
        death_scr.visible = true;
        # visible = false;
        position = Vector3.UP * 100;
        GlobalVariables.paused = true;

func _physics_process(dt: float) -> void:
    if not syncro.is_multiplayer_authority() or dead:
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

    if position.y < -100:
        rpc("die");
