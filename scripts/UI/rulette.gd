extends Control

signal selected_change(value: bool)

var randomNum = randi_range(10,20);
var selected = true;

@onready var pink: TextureRect = $Pink
@onready var blue: TextureRect = $Blue
@onready var sound_1: AudioStreamPlayer = $Sound1
@onready var sound_2: AudioStreamPlayer = $Sound2
@onready var fade: AnimationPlayer = $Fade

func select() -> void:
	fade.play("fade_in")
	await get_tree().create_timer(0.5).timeout
	
	for i in range(randomNum):
		if selected:
			sound_1.play()
			blue.scale = Vector2(1.0, 1.0);
			blue.position = Vector2(1078.083, 290.002)
			
			pink.scale = Vector2(1.3, 1.3);
			pink.position = Vector2(1140.083, 329.002)
			selected = false
		else:
			sound_1.play()
			pink.scale = Vector2(1.0, 1.0);
			pink.position = Vector2(1131.083, 329.002)
			
			blue.scale = Vector2(1.3, 1.3);
			blue.position = Vector2(1068.083, 290.002)
			selected = true
		await get_tree().create_timer(0.13).timeout
		
	emit_signal("selected_change", selected)
	
	sound_2.play()
	await get_tree().create_timer(3.0).timeout
	fade.play("fade_out")
	
func _ready() -> void:
	select()
	
