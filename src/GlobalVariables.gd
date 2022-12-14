extends Node

var network_port : int = 42069;
var network_is_host : bool = false;
var network_ip : String = "127.0.0.1";

var paused : bool = false : set = _set_paused;

func _set_paused(val: bool):
    paused = val;
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE
        if paused else Input.MOUSE_MODE_CAPTURED);
