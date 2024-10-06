class_name Player
extends CharacterBody3D

@onready
var capture_hitbox: Area3D = $%CaptureBox

@onready
var suck_hitbox: Area3D = $%SuckBox

const JUMP_VELOCITY = 4.5

@onready
var mesh: MeshInstance3D = $BodyMesh
@onready
var real_mesh: Node3D = $player
@onready
var anim_player: AnimationPlayer = $player/AnimationPlayer
@onready
var crown: Node3D = $%crown

var stun_time = -1
var suck_time = -1
var suck_cd = -1
var time_to_stun = 1
var sucking_ready = true

func _ready() -> void:
	Signals.upgrade_net.connect(net_upgrade_handle)
	Globals.player = self

func _physics_process(delta: float) -> void:
	stun_time -= delta
	suck_time -= delta
	suck_cd -= delta
	if position.y < -5:
		position = Vector3(0, 1, 0)
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
		var adj = real_mesh.global_position
		real_mesh.look_at(adj + -direction)
	
	move_and_slide()
	
	Globals.player_pos = self.global_position
	
	if (suck_cd < 0 && Input.is_action_just_pressed("suck")):
		suck_time = 5.0
		suck_cd = 30
		$%Sucking.play(.5)
		sucking_ready = false
	var suck_value = 100
	if suck_cd > 0:
		suck_value -= 100 * suck_cd / 30
	Globals.game.suck_meter.value = suck_value
	
	if suck_time > 0:
		suck()
	
	if (stun_time < 0 && Input.is_action_just_pressed("capture")):
		capture()
		
	animation(direction)

func capture() -> void:
	stun_time = time_to_stun
	var things = capture_hitbox.get_overlapping_areas()
	anim_player.stop()
	anim_player.play("swing")
	if things.size() > 0:
		for thing in things:
			thing.get_parent().catch()
	$%Swing.play()

func suck() -> void:
	var things = suck_hitbox.get_overlapping_bodies()
	if (things.size() > 0):
		for thing in things:
			thing.suck_towards = suck_hitbox.global_position

func net_upgrade_handle() -> void:
	print("upgrading net")
	capture_hitbox.scale *= 2
	$%net.scale *= 1.5

func animation(direction: Vector3):
	if stun_time > 0:
		pass
	elif (direction != Vector3.ZERO):
		anim_player.play("move")
	else:
		anim_player.stop()
		anim_player.play("idle")
