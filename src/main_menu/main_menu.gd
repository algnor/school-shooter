extends Control

@onready var networking_menu = get_parent().get_node("Networking Menu")

func _ready():
    pass

func _process(_delta):
    pass


func _on_start_button_pressed():
    visible = false
    networking_menu.visible = true


func _on_options_button_pressed():
    get_tree().change_scene_to_file("res://assets/scenes/options_menu.tscn")

func _on_exit_button_pressed():
    get_tree().quit()
