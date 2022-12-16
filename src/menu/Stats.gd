extends Control

@onready var _health := $HealthBar;
@onready var _ammo   := $Ammo;
@onready var _skill  := $Skill;

func update_health(health: int, max_health: int):
    #print("Stats: ", health, "/", max_health);
    _health.max_value = max_health;
    _health.value = health;

func update_ammo(ammo: int, max_ammo: int):
    _ammo.text = "%d/%d" % [ammo, max_ammo];

func update_skill(time_left: float, wait_time: float):
    var percent = (wait_time-time_left)/wait_time;
    _skill.value = _skill.max_value*percent;
