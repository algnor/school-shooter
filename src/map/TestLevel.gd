extends Node3D

func _ready():
    var multiplayer_peer = ENetMultiplayerPeer.new();

    if GlobalVariables.network_is_host:
        multiplayer_peer.create_server(GlobalVariables.network_port, 100);
        multiplayer.multiplayer_peer = multiplayer_peer;
        multiplayer_peer.peer_connected.connect(func(id) : add_player_character(id));
        multiplayer_peer.peer_disconnected.connect(func(id) : remove_player_character(id));
        add_player_character();

    else:
        multiplayer_peer.create_client(
            GlobalVariables.network_ip,
            GlobalVariables.network_port
        );
        multiplayer.multiplayer_peer = multiplayer_peer;

func add_player_character(id = 1):
    var character = preload("res://assets/scenes/Player.tscn").instantiate();
    character.name = str(id);
    $Players.add_child(character);
    # FIXME: only works for host for some reason
    # moved down floor to keep clients from infinitely falling
    # character.position.y = 5;

func remove_player_character(id = 1):
    $Players.get_node(str(id)).queue_free()
