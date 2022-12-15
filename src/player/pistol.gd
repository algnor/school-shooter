extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var sound = $Shot

func shoot():
    if anim_player.is_playing():
        pass
    else:
        anim_player.play("Kick")
        sound.set_pitch_scale(randf_range(.7,.9))
