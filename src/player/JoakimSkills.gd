extends Node

static func _shoot(p: Player) -> void:
    p.gun.shoot();
    print(p.name, " shot");
    
static func _skill(p: Player) -> void:
    print(p.name, " used skill");
