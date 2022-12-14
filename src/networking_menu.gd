extends Control

func _change_scene() -> void:
    get_tree().change_scene_to_file("res://assets/scenes/test_level.tscn");
    GlobalVariables.paused = false;
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _on_connect(is_host: bool) -> void:
    GlobalVariables.network_ip = $Panel/VBoxContainer/Ip.text;
    GlobalVariables.network_port = int($Panel/VBoxContainer/Port.text);
    GlobalVariables.network_is_host = is_host;
    _change_scene();
