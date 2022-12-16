extends Resource
class_name BaseCharacter

@export_group("Speed")
@export var speed : float = 5.0;
@export var speed_sprint : float = 15.0;
@export var speed_crouch : float = 1.0;
@export var jump_velocity : float = 5.0;
@export var crouch_speed : float = 0.1;

@export_group("Stats")
@export var max_health : int = 100;
@export var max_ammo : int = 30;
@export var timeout_shoot : float = 0.3;
@export var timeout_skill : float = 10.0;
@export var timeout_reload : float = 2.0;

@export_group("Height")
@export var height : float = 2.0;
@export var height_crouch : float = 1.5;
@export var eye_height : float = 1.8;
@export var eye_height_crouch : float = 1.2;

@export_group("Skills")
# Exporting Callables directly does not seem to work
@export var skills_object : Resource;
@export var function_shoot : String = "_shoot";
@export var function_skill : String = "_skill";
@export var function_reload : String = "_reload";

@export_group("Models")
@export var model_player : Mesh = CapsuleMesh.new();
@export var model_weapon : Mesh;
