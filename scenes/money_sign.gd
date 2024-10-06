extends Node3D

var time_left = 1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("move")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	if time_left < 0:
		queue_free()

func set_amt(amt: int) -> void:
	$Label3D.text = "$%s" % amt
