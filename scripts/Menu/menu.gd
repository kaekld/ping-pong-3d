extends Control

@onready var margin_container: MarginContainer = $MarginContainer

@onready var name_input: Control = $NameInput

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var input: Label = $NameInput/Input
@onready var label: Label = $NameInput/Label

var active_input: bool = false
var change_input: bool = false
var sp_input: bool = false
	
func _ready() -> void:
	animation_player.play("fade_in")
	
func _on_play_mp_pressed() -> void:
	GLOBAL.sp_play = false
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	margin_container.visible = false
	
	name_input.visible = true
	active_input = true
	
	animation_player.play("fade_in")
	await animation_player.animation_finished

func _input(event) -> void:
	if event is InputEventKey and event.pressed and active_input:
		if event.keycode == KEY_BACKSPACE:
			input.text = input.text.substr(0, input.text.length()-1)
			return
			
		if event.keycode == KEY_ENTER and !change_input and !sp_input:	
			GLOBAL.name_p1 = input.text;
			animation_player.play("fade_out")
			await animation_player.animation_finished
			label.text = "NOMBRE DEL JUGADOR 2"
			input.text = ""
			animation_player.play("fade_in")
			change_input = true
			
		elif event.keycode == KEY_ENTER and change_input and !sp_input:
			GLOBAL.name_p2 = input.text;
			animation_player.play("fade_out")
			await animation_player.animation_finished
			GLOBAL.scene_to_load = "res://scenes/MainMap.tscn"
			get_tree().change_scene_to_file("res://scenes/LoadingScreen.tscn")
			
		elif event.keycode == KEY_ENTER and sp_input:
			GLOBAL.name_p1 = input.text
			animation_player.play("fade_out")
			await animation_player.animation_finished
			GLOBAL.scene_to_load = "res://scenes/MainMap.tscn"
			get_tree().change_scene_to_file("res://scenes/LoadingScreen.tscn")
			
		if !(event.keycode == KEY_ENTER):	
			input.text += event.as_text_key_label()
	
func _on_play_sp_pressed() -> void:
	sp_input = true
	GLOBAL.sp_play = true
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	margin_container.visible = false
	
	label.text = "NOMBRE DEL JUGADOR"
	name_input.visible = true
	active_input = true
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
