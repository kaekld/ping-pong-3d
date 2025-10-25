extends Node3D

@onready var label_score_p1: Label = $UI/ScoreP1
@onready var label_score_p2: Label = $UI/ScoreP2
@onready var point: AudioStreamPlayer = $Point
@onready var anim_font: AnimationPlayer = $UI/AnimationUI
@onready var player_1: CharacterBody3D = $PlayersViewPorts/HBoxContainer/SubViewportContainer/SubViewport/Player1
@onready var player_2: CharacterBody3D = $PlayersViewPorts/HBoxContainer/SubViewportContainer2/SubViewport/Player2
@onready var timer: Timer = $TimerNode/Timer
@onready var timer_label_p_1: Label3D = $TimerNode/TimerLabelP1
@onready var timer_label_p_2: Label3D = $TimerNode/TimerLabelP2
@onready var turn_p2: TextureRect = $UI/TurnP2
@onready var turn_p1: TextureRect = $UI/TurnP1
@onready var sound_1: AudioStreamPlayer = $Sound1
@onready var label_p_1: Label = $UI/LabelP1
@onready var label_p_2: Label = $UI/LabelP2
@onready var sub_viewport_container_2: SubViewportContainer = $PlayersViewPorts/HBoxContainer/SubViewportContainer2
@onready var camera_p_1: Camera3D = $PlayersViewPorts/HBoxContainer/SubViewportContainer/SubViewport/CameraP1
@onready var score_p_2: Label = $UI/ScoreP2

var ball_scene = preload("res://scenes/Ball.tscn")
var rulette_scene = preload("res://scenes/Rulette.tscn")

var remain_seconds: int = 180
var scorep1: int = 0
var scorep2: int = 0
var rulette: Control
var ball: Node3D
var selected: bool
var tie_breaker: bool = false
var end_play: bool = false

const PLAYER_1_START_POS = Vector3(0, 0, 4.607)
const PLAYER_2_START_POS = Vector3(0, 0, -1.807)
const BALL_START_POS = Vector3(0.0, 0.159, 1.456)
const BALL_SPEED = 6.0


func init_rulette() -> void:
	rulette = rulette_scene.instantiate()
	rulette.position = Vector2(0, 15)
	add_child(rulette)
	rulette.connect("selected_change", _on_rulette_selected_change)
	await get_tree().create_timer(8.0).timeout
	rulette.queue_free()


func spawn_ball(throw_direction: Vector3) -> void:
	ball = ball_scene.instantiate()
	ball.speed = BALL_SPEED
	ball.initial_dir = throw_direction
	ball.position = BALL_START_POS
	
	ball.collision_layer = 1 << 2  
	ball.collision_mask = 1 << 2
	add_child(ball)


func restart_ball(throw_direction: Vector3) -> void:
	clear_ball()
	await get_tree().create_timer(1.0).timeout
	
	show_player_turn_indicator()
	spawn_ball(Vector3.ZERO)
	
	await get_tree().create_timer(3.0).timeout
	clear_ball()
	spawn_ball(throw_direction)
	
	hide_turn_indicators()
	reset_animation()
	timer.start()


func show_player_turn_indicator() -> void:
	if selected:
		turn_p2.visible = true
		anim_font.play("pink_arrow")
		selected = false
	else:
		turn_p1.visible = true
		anim_font.play("blue_arrow")


func hide_turn_indicators() -> void:
	turn_p2.visible = false
	turn_p1.visible = false


func reset_animation() -> void:
	anim_font.stop()
	anim_font.play("smoth")


func clear_ball() -> void:
	if ball and is_instance_valid(ball):
		ball.queue_free()


func setup_single_player() -> void:
	sub_viewport_container_2.visible = false
	camera_p_1.fov = 77.5
	label_p_2.position = Vector2(3.0, 13.0)
	score_p_2.position = Vector2(1016.0, 528.0)


func _ready() -> void:
	hide_turn_indicators()
	
	if GLOBAL.sp_play:
		setup_single_player()
	
	anim_font.play("fade_in")
	await anim_font.animation_finished
	
	anim_font.play("smoth_sp" if GLOBAL.sp_play else "smoth")
	
	player_1.connect("increment", _on_player_increment)
	player_2.connect("increment", _on_player_increment)
	spawn_ball(Vector3.ZERO)
	init_rulette()


func _process(delta: float) -> void:
	if GLOBAL.sp_play and ball and is_instance_valid(ball):
		track_ball()
	
	handle_game_end_conditions()


func handle_game_end_conditions() -> void:
	if remain_seconds == 0 and scorep1 == scorep2 and not tie_breaker:
		start_tie_breaker()
	
	if remain_seconds == 0 and not end_play:
		end_play = true
		handle_time_up_victory()


func start_tie_breaker() -> void:
	tie_breaker = true
	clear_ball()
	reset_player_positions()
	spawn_ball(Vector3.ZERO)
	init_rulette()


func handle_time_up_victory() -> void:
	if scorep1 > scorep2:
		declare_winner(label_p_1, GLOBAL.name_p1)
	elif scorep2 > scorep1:
		declare_winner(label_p_2, GLOBAL.name_p2)


func declare_winner(label: Label, player_name: String) -> void:
	clear_ball()
	label.text = player_name + " Wins"
	label.visible = true
	end_game()


func end_game() -> void:
	await get_tree().create_timer(5.0).timeout
	anim_font.play("fade_out")
	await anim_font.animation_finished
	GLOBAL.scene_to_load = "res://scenes/Menu.tscn"
	get_tree().change_scene_to_file("res://scenes/LoadingScreen.tscn")


func handle_goal(scorer: int, ball_direction: Vector3) -> void:
	point.play()
	timer.stop()
	
	if scorer == 1:
		scorep1 += 1
		label_score_p1.text = str(scorep1)
	else:
		scorep2 += 1
		label_score_p2.text = str(scorep2)
	
	GLOBAL.velocity = 5
	reset_player_positions()
	
	if (scorer == 1 and scorep1 >= 5) or (scorer == 2 and scorep2 >= 5) or tie_breaker:
		var winner_label = label_p_1 if scorer == 1 else label_p_2
		var winner_name = GLOBAL.name_p1 if scorer == 1 else GLOBAL.name_p2
		declare_winner(winner_label, winner_name)
	else:
		restart_ball(ball_direction)


func reset_player_positions() -> void:
	player_1.position = PLAYER_1_START_POS
	player_2.position = PLAYER_2_START_POS


func _on_goal_p_1_body_entered(body: Node3D) -> void:
	handle_goal(2, Vector3(0.0, 0.0, -1.0))


func _on_goal_p_2_body_entered(body: Node3D) -> void:
	selected = true
	handle_goal(1, Vector3(0.0, 0.0, 1.0))


func _on_rulette_selected_change(value: bool) -> void:
	await get_tree().create_timer(2.0).timeout
	clear_ball()
	
	var direction = Vector3(0.0, 0.0, -1.0) if not value else Vector3(0.0, 0.0, 1.0)
	spawn_ball(direction)
	
	timer.start()


func _on_player_increment() -> void:
	if ball and is_instance_valid(ball):
		ball.speed = GLOBAL.velocity


func _on_timer_timeout() -> void:
	if remain_seconds > 0:
		remain_seconds -= 1
	
	update_timer_display()


func update_timer_display() -> void:
	var minutes = int(remain_seconds / 60)
	var seconds = int(remain_seconds % 60)
	var time_string = "%02d:%02d" % [minutes, seconds]
	
	timer_label_p_1.text = time_string
	timer_label_p_2.text = time_string


func track_ball() -> void:
	var player_pos = player_2.position
	var ball_pos = ball.position
	player_pos.x = lerp(player_pos.x, ball_pos.x, 0.2)
	player_pos.x = clamp(player_pos.x, -4.5, 4.5)
	player_2.position = player_pos


func play_turn_sound() -> void:
	sound_1.play()
