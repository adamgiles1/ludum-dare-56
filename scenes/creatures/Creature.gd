class_name Creature
extends CharacterBody3D

@export
var speed := 2.0

@export
var value := 1

@onready
var mesh = $Mesh
@onready
var real_mesh = $butterfly

var time_till_next_command := 1.0
var current_command: Vector3 = Vector3.ZERO
var is_caught = false
var caught_time_left
var suck_towards: Vector3 = Vector3.INF
var suck_power := 20.0

@onready
var anim_player: AnimationPlayer = $butterfly/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_caught:
		caught_time_left -= delta
		if caught_time_left < 0:
			queue_free()
		return
	else:
		anim_player.play("Armature|ArmatureAction", -1, speed)
	
	time_till_next_command -= delta
	var direction = get_dir()
	
	if (direction):
		mesh.look_at(mesh.global_position + direction)
		real_mesh.look_at(real_mesh.global_position + direction)
	
	if suck_towards != Vector3.INF:
		direction = suck_towards - position
		velocity.x = direction.x * suck_power
		velocity.z = direction.z * suck_power
		suck_towards = Vector3.INF
	elif direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func get_dir() -> Vector3:
	if time_till_next_command < 0:
		time_till_next_command = randf_range(.5, 2)
		if randi_range(0, 1) == 2:
			current_command = Vector3.ZERO
		current_command = Vector3(1, 0, 0).rotated(Vector3.UP, deg_to_rad(randi_range(0, 360)))
	return current_command

func catch() -> void:
	if (is_caught):
		return
	is_caught = true
	caught_time_left = .5
	var tween = get_tree().create_tween()
	tween.tween_property(real_mesh, "scale", Vector3.ZERO, .4)
	Globals.game.creature_caught(value, global_position)
	if Globals.blops_this_tick < 3:
		$CaughtSound.play()
	Globals.blops_this_tick += 1
