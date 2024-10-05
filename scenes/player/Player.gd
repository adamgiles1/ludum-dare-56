class_name Player
extends CharacterBody3D

@onready
var capture_hitbox: Area3D = $%CaptureBox

const JUMP_VELOCITY = 4.5

@onready
var mesh: MeshInstance3D = $BodyMesh
@onready
var anim_player: AnimationPlayer = $AnimationPlayer

var stun_time = -1
var time_to_stun = .25

func _ready() -> void:
	Signals.upgrade_net.connect(net_upgrade_handle)

func _physics_process(delta: float) -> void:
	stun_time -= delta
	if position.y < -5:
		position = Vector3(0, 1, 0)
	#print("x: %s, y: %s" % [position.x, position.z])
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if stun_time > 0:
		direction = Vector3.ZERO
	if direction:
		velocity.x = direction.x * Globals.game.char_speed
		velocity.z = direction.z * Globals.game.char_speed
	else:
		velocity.x = move_toward(velocity.x, 0, Globals.game.char_speed)
		velocity.z = move_toward(velocity.z, 0, Globals.game.char_speed)
	
	# rotate player mesh
	if (direction):
		mesh.look_at(mesh.global_position + direction)


	move_and_slide()
	
	Globals.player_pos = self.global_position
	
	if (stun_time < 0 && Input.is_action_just_pressed("capture")):
		capture()

func capture() -> void:
	stun_time = time_to_stun
	var things = capture_hitbox.get_overlapping_areas()
	anim_player.play("capture")
	if things.size() > 0:
		for thing in things:
			thing.get_parent().catch()

func net_upgrade_handle() -> void:
	print("upgrading net")
	capture_hitbox.scale *= 2
