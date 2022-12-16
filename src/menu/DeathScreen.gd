extends Control

func _on_respawn_pressed():
    GlobalVariables.paused = false;
    GlobalVariables.current_player._reload_vars();
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _on_quit_pressed():
    GlobalVariables.camera_set = false;
    get_tree().change_scene_to_file("res://assets/scenes/menu.tscn");
    multiplayer.multiplayer_peer.close();
