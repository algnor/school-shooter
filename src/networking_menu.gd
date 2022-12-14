extends Control

func _change_scene():
    get_tree().change_scene_to_file("res://assets/scenes/test_level.tscn")


func _on_join_button_pressed():
    GlobalVariables.network_ip = str($Panel/VBoxContainer/Ip.text)
    GlobalVariables.network_port = str($Panel/VBoxContainer/Port.text).to_int()
    GlobalVariables.network_is_host = false
    _change_scene()


func _on_host_button_pressed():
    GlobalVariables.network_ip = str($Panel/VBoxContainer/Ip.text)
    GlobalVariables.network_port = str($Panel/VBoxContainer/Port.text).to_int()
    GlobalVariables.network_is_host = true
    _change_scene()
