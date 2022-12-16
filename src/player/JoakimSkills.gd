static func _shoot(p: Player) -> void:
    print(p.name, " shot");
    p.gun.shoot();
    p.shoot_dmg(5);

static func _skill(p: Player) -> void:
    print(p.name, " used skill");
    print(p.name, " hp:", p.health, " ammo:", p.ammo, " dead:", p.dead);
