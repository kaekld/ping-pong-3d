extends RigidBody3D

@export var speed := 5.0
@export var initial_dir := Vector3(1, 0, 1)

func _ready():
	linear_velocity = initial_dir.normalized() * speed

func _integrate_forces(state):
	var vel = state.get_linear_velocity()
	vel.y = 0
	vel = vel.normalized() * speed
	state.set_linear_velocity(vel)
