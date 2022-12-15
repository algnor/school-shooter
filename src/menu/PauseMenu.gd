extends Control

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        GlobalVariables.paused = !GlobalVariables.paused;
        visible = GlobalVariables.paused;
        # Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE
        #     if GlobalVariables.paused else Input.MOUSE_MODE_CAPTURED);

# func _process(dt):
#     visible = GlobalVariables.paused;
#     Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE
#         if GlobalVariables.paused else Input.MOUSE_MODE_CAPTURED);

func _on_resume_button_pressed():
    GlobalVariables.paused = false;
    visible = GlobalVariables.paused;
    # Input.set_mouse_mode(Input.MOUSE_MODE_CAPUTRED);

func _on_quit_button_pressed():
    GlobalVariables.camera_set = false;
    get_tree().change_scene_to_file("res://assets/scenes/menu.tscn");
    multiplayer.multiplayer_peer.close();
