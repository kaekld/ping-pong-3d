extends CharacterBody3D

signal increment

@export var speed := 5.0
@export var dash_speed := 15.0
@export var dash_duration := 0.2   

var is_dashing := false
var dash_time := 0.0
var dash_direction := 0  

func _physics_process(delta):
	var move_dir = Vector3.ZERO

	var move_right = Input.is_action_pressed("RightP2")
	var move_left = Input.is_action_pressed("LeftP2")

	if move_right:
		move_dir.x += 1
	if move_left:
		move_dir.x -= 1

	if not is_dashing:
		if Input.is_action_just_pressed("DashP2") and move_right:
			is_dashing = true
			dash_time = dash_duration
			dash_direction = 1
		elif Input.is_action_just_pressed("DashP2") and move_left:
			is_dashing = true
			dash_time = dash_duration
			dash_direction = -1

	if is_dashing:
		move_dir.x = dash_direction
		move_dir = move_dir.normalized() * dash_speed
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
	else:
		move_dir = move_dir.normalized() * speed

	velocity.x = move_dir.x
	velocity.z = 0
	velocity.y = 0

	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ball") and body is RigidBody3D:
		if $HitSound.playing:
			$HitSound.stop()
		$HitSound.play()
		
		GLOBAL.velocity += 0.2
		emit_signal("increment")
		
		var direction = (body.global_position - global_position).normalized()
		direction.y = 0
		
		var local_hit = to_local(body.global_position)
		var effect = local_hit.x * 0.5 
		direction.x += effect
		direction = direction.normalized()

		var strengh = direction * 5.0
		body.linear_velocity = Vector3.ZERO  
		body.apply_central_impulse(strengh)
