extends Node

static func _shoot(p: Player) -> void:
    print(p.name, " shot");
    
static func _skill(p: Player) -> void:
    print(p.name, " used skill");
