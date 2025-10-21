extends Control

@onready var play_sp: Button = $MarginContainer/VBoxContainer/PlaySP
@onready var play_mp: Button = $MarginContainer/VBoxContainer/PlayMP
@onready var exit: Button = $MarginContainer/VBoxContainer/Exit
@onready var name_input: Control = $NameInput

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var input: Label = $NameInput/Input
@onready var label: Label = $NameInput/Label


var active_input: bool = false
	
func _ready() -> void:
	animation_player.play("fade_in")
	
func _on_play_mp_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	play_mp.visible = false
	play_sp.visible = false
	exit.visible = false
	
	name_input.visible = true
	active_input = true
	
	animation_player.play("fade_in")
	await animation_player.animation_finished

func _input(event) -> void:
	if event is InputEventKey and event.pressed and active_input:
		if event.keycode == KEY_BACKSPACE:
			input.text = input.text.substr(0, input.text.length()-1)
			return
		if event.keycode == KEY_ENTER:
			if GLOBAL.name_p1 == "":
				GLOBAL.name_p1 = input.text;
				
				animation_player.play("fade_out")
				await animation_player.animation_finished
				label.text = "NOMBRE DEL JUGADOR 2"
				input.text = ""
				animation_player.play("fade_in")
			else:
				GLOBAL.name_p2 = input.text;
				
				animation_player.play("fade_out")
				await animation_player.animation_finished
				
				GLOBAL.scene_to_load = "res://scenes/MainMap.tscn"
				get_tree().change_scene_to_file("res://scenes/LoadingScreen.tscn")
			
		if !(event.keycode == KEY_ENTER):	
			input.text += event.as_text_key_label()
	
