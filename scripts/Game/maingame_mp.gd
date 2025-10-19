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

var ball_scene = preload("res://scenes/Ball.tscn")
var rulette_scene = preload("res://scenes/Rulette.tscn")

var remain_seconds : int = 180

var scorep1 = 0
var scorep2 = 0

var rulette: Control;
var	ball: Node3D;
var selected: bool

func init_rulette() -> void:
	rulette = rulette_scene.instantiate()
	rulette.position = Vector2(0, 15)
	add_child(rulette)
	rulette.connect("selected_change", Callable(self, "_on_rulette_selected_change"))
	await get_tree().create_timer(8.0).timeout
	rulette.queue_free()
	
func spawn_ball(trow_direction: Vector3) -> void:
	ball = ball_scene.instantiate()
	ball.speed = 6.0
	ball.initial_dir = trow_direction
	ball.position = Vector3(0.0, 0.159, 1.456)
	
	ball.collision_layer = 1 << 2  
	ball.collision_mask = 1 << 2
	add_child(ball)

func restart_ball(trow_direction: Vector3) -> void:
	ball.queue_free()
	await get_tree().create_timer(1.0).timeout
	
	if selected:
		turn_p2.visible = true
		anim_font.play("pink_arrow")
		selected = false
	else:
		turn_p1.visible = true
		anim_font.play("blue_arrow")
		
	spawn_ball(Vector3(0.0, 0.0, 0.0))
	await get_tree().create_timer(3.0).timeout
	ball.queue_free()
	spawn_ball(trow_direction)
	
	turn_p2.visible = false
	turn_p1.visible = false
	
	anim_font.stop()
	anim_font.play("smoth")
			
	timer.start()

func _ready() -> void:
	turn_p2.visible = false
	turn_p1.visible = false
	anim_font.play("smoth")
	player_1.connect("increment", Callable(self, "_on_player_1_increment"))
	player_2.connect("increment", Callable(self, "_on_player_1_increment"))
	spawn_ball(Vector3(0.0, 0.0, 0.0))
	init_rulette()

func _on_goal_p_1_body_entered(body: Node3D) -> void:
	point.play()
	timer.stop()
	scorep2 += 1
	label_score_p2.text = str(scorep2)
	GLOBAL.velocity = 5;
	player_1.position = Vector3(0, 0, 4.607)
	player_2.position = Vector3(0, 0, -1.807)
	restart_ball(Vector3(0.0, 0.0, 1.0))

func _on_goal_p_2_body_entered(body: Node3D) -> void:
	point.play()
	selected = true
	timer.stop()
	scorep1 += 1
	label_score_p1.text = str(scorep1)
	GLOBAL.velocity = 5;
	restart_ball(Vector3(0.0, 0.0, -1.0))

func _on_rulette_selected_change(value: bool) -> void:
	await get_tree().create_timer(2.0).timeout
	ball.queue_free()
	if !value: 
		spawn_ball(Vector3(0.0, 0.0, -1.0))
	else: 
		spawn_ball(Vector3(0.0, 0.0, 1.0))
		
	timer.start()
		
func _on_player_1_increment() -> void:
	ball.speed = GLOBAL.velocity
	print(GLOBAL.velocity)

func _on_player_2_increment() -> void:
	ball.speed = GLOBAL.velocity
	print(GLOBAL.velocity)

func _on_timer_timeout() -> void:
	
	remain_seconds -= 1
	var min = int(remain_seconds/60)
	var sec = int(remain_seconds%60)
	var time = "%02d:%02d" % [min,sec]
	timer_label_p_1.text = str(time)
	timer_label_p_2.text = str(time)
	
func play_turn_sound() -> void:
	sound_1.play()
