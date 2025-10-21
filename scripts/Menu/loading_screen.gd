extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var scene_name = GLOBAL.scene_to_load
var load_status: int = 0
var time_waited: float = 0.0
var scene_ready: bool = false 

func _ready() -> void:
	animation_player.play("loading")
	ResourceLoader.load_threaded_request(scene_name)
	
func _process(delta):
	time_waited += delta
	load_status = ResourceLoader.load_threaded_get_status(scene_name)
	
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_ready = true
		
	if scene_ready and time_waited >= 2:
		var new_scene = ResourceLoader.load_threaded_get(scene_name)
		get_tree().change_scene_to_packed(new_scene)
	
