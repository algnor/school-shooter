extends Node3D



func _ready():
    var multiplayer_peer = ENetMultiplayerPeer.new()
    
    if GlobalVariables.network_is_host == true:
        multiplayer_peer.create_server(GlobalVariables.network_port, 100)
        multiplayer.multiplayer_peer = multiplayer_peer
        multiplayer_peer.peer_connected.connect(func(id) : add_player_character(id))
        add_player_character()
    
    else:
        multiplayer_peer.create_client(GlobalVariables.network_ip, GlobalVariables.network_port)
        multiplayer.multiplayer_peer = multiplayer_peer


func _process(_delta):
    pass

func add_player_character(id = 1):
    var character = preload("res://assets/scenes/player.tscn").instantiate()
    character.name = str(id)
    add_child(character)
