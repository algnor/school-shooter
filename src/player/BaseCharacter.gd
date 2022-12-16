extends Resource
class_name BaseCharacter

@export_group("Speed")
@export var speed : float = 5.0;
@export var speed_sprint : float = 15.0;
@export var speed_crouch : float = 1.0;
@export var jump_velocity : float = 5.0;
@export var crouch_speed : float = 0.1;

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

@export_group("Models")
@export var model_player : Mesh = CapsuleMesh.new();
@export var model_weapon : Mesh;
