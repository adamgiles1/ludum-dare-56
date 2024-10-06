extends Camera3D

var camera_speed = .015

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_x = Globals.player_pos.x
	var target_z = Globals.player_pos.z + 4.5
	
	var x = move_toward(global_position.x, target_x, camera_speed)
	var z = move_toward(global_position.z, target_z, camera_speed)
	
	
	
	global_position.x = limit_diff_to(x, target_x, 1)
	global_position.z = limit_diff_to(z, target_z, 1)
	global_position.y = 7

func limit_diff_to(from: float, to: float, max_diff) -> float:
	if abs(from - to) > max_diff:
		return to + max_diff if from > to else to - max_diff
	return from
