class_name Game
extends Node3D

@onready
var creature_scn1 := preload("res://scenes/creatures/CreatureOne.tscn")
@onready
var creature_scn2 := preload("res://scenes/creatures/CreatureTwo.tscn")
@onready
var creature_scn3 := preload("res://scenes/creatures/CreatureThree.tscn")

var time_till_spawn := 0.0

var time_between_spawn := 5.0
var net_size = 1
var char_speed = 5
var creature_tier = 1

var money = 0
@onready
var money_label: RichTextLabel = $%MoneyLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game = self
	init_buttons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_till_spawn -= delta
	if time_till_spawn < 0:
		time_till_spawn = time_between_spawn
		spawn_creature()

func get_creature_scn() -> Creature:
	if creature_tier >= 3 && randi_range(1,10) == 2:
		return creature_scn3.instantiate()
	elif creature_tier >= 2 && randi_range(1,5) == 2:
		return creature_scn2.instantiate()
	return creature_scn1.instantiate()

func spawn_creature() -> void:
	var current_creatures = $Creatures.get_child_count()
	if current_creatures > 500:
		return
	var x = randf_range(-25, 25)
	var z = randf_range(-30, 10)
	print("spawning creature at coords %s %s. There is now %s creatures" % [x, z, current_creatures])
	var init: Creature = get_creature_scn()
	init.position.x = x
	init.position.y = 0
	init.position.z = z
	$Creatures.add_child(init)

func creature_caught(value: int) -> void:
	print("caught creature with value %s" % value)
	set_money(money + value)

func set_money(num: int) -> void:
	money = num
	money_label.text = "💲" + str(num)

func init_buttons() -> void:
	var net_button = $%NetButton
	net_button.pressed.connect(handle_net_but)
	net_button.focus_mode = Button.FOCUS_NONE
	
	var speed_button = $%SpeedButton
	speed_button.pressed.connect(handle_speed_but)
	speed_button.focus_mode = Button.FOCUS_NONE

	var spawn_button = $%SpawnButton
	spawn_button.pressed.connect(handle_spawn_but)
	spawn_button.focus_mode = Button.FOCUS_NONE

	var better_creatures_button = $%BetterCreaturesButton
	better_creatures_button.pressed.connect(handle_better_creatures_but)
	better_creatures_button.focus_mode = Button.FOCUS_NONE

func handle_net_but():
	print("purchased net")

func handle_speed_but():
	print("purchased speed")
	char_speed *= 1.2

func handle_spawn_but():
	print("purchased spawn")
	if time_between_spawn > 2:
		time_between_spawn -= 1
	else:
		time_between_spawn *= .8

func handle_better_creatures_but():
	print("purchased better creatures")
	creature_tier += 1
