class_name Game
extends Node3D

@onready
var creature_scn1 := preload("res://scenes/creatures/CreatureOne.tscn")
@onready
var creature_scn2 := preload("res://scenes/creatures/CreatureTwo.tscn")
@onready
var creature_scn3 := preload("res://scenes/creatures/CreatureThree.tscn")
@onready
var money_sign := preload("res://scenes/MoneySign.tscn")

@onready
var music: AudioStreamPlayer = $Music

var time_till_spawn := 0.0

var time_between_spawn := 5.0
var net_size = 1
var char_speed = 5
var creature_tier = 1

var net_button
var speed_button
var spawn_button
var better_creatures_button
var multi_button
var net_price = 50
var speed_price = 5
var creature_tier_price = 10
var multi_price = 5
var spawn_price = 5
var money_mult = 1.0

var money = 0
@onready
var money_label: RichTextLabel = $%MoneyLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game = self
	init_buttons()
	var music: AudioStreamPlayer = $Music

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Globals.blops_this_tick = 0
	time_till_spawn -= delta
	if time_till_spawn < 0:
		time_till_spawn = time_between_spawn
		spawn_creature()
	update_store()
	set_money(money)
	
	if !music.playing:
		music.play()
	
	if Input.is_action_just_pressed("ui_end"):
		#todo remove
		money += 1000

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
	var x = randf_range(-17, 18)
	var z = randf_range(-28, 8)
	var init: Creature = get_creature_scn()
	init.position.x = x
	init.position.y = 0
	init.position.z = z
	$Creatures.add_child(init)

func creature_caught(value: int, pos: Vector3) -> void:
	print("caught creature with value %s and multiplier %s" % [value, money_mult])
	set_money(money + value * money_mult)
	var sign = money_sign.instantiate()
	sign.global_position = pos
	sign.set_amt(value * money_mult)
	add_child(sign)

func set_money(num: int) -> void:
	money = num
	var disp = str(money) if money < 100000 else str(money / 1000) + "K"
	money_label.text = "[outline_size=12]$%s[/outline_size]" % disp

func init_buttons() -> void:
	net_button = $%NetButton
	net_button.pressed.connect(handle_net_but)
	net_button.focus_mode = Button.FOCUS_NONE
	net_button.visible = false
	
	speed_button = $%SpeedButton
	speed_button.pressed.connect(handle_speed_but)
	speed_button.focus_mode = Button.FOCUS_NONE
	speed_button.visible = false

	spawn_button = $%SpawnButton
	spawn_button.pressed.connect(handle_spawn_but)
	spawn_button.focus_mode = Button.FOCUS_NONE
	spawn_button.visible = false

	better_creatures_button = $%BetterCreaturesButton
	better_creatures_button.pressed.connect(handle_better_creatures_but)
	better_creatures_button.focus_mode = Button.FOCUS_NONE
	better_creatures_button.visible = false
	
	multi_button = $%MultiButton
	multi_button.pressed.connect(handle_multi_but)
	multi_button.focus_mode = Button.FOCUS_NONE
	multi_button.visible = false

func handle_net_but():
	money -= net_price
	net_price *= 10
	if net_price > 6000:
		net_price = 9223372036854775807
		net_button.visible = false
	print("purchased net")
	net_size += 1
	Signals.upgrade_net.emit()
	net_button.disabled = true

func handle_speed_but():
	money -= speed_price
	speed_price *= 5
	if speed_price > 6000:
		speed_price = 9223372036854775807
		speed_button.visible = false
	print("purchased speed")
	char_speed *= 1.25
	speed_button.disabled = true

func handle_spawn_but():
	print("purchased spawn")
	money -= spawn_price
	spawn_price *= 5
	if spawn_price > 5000:
		spawn_price = 9223372036854775807
		spawn_button.visible = false
	time_between_spawn *= .37
	spawn_button.disabled = true

func handle_better_creatures_but():
	print("purchased better creatures")
	money -= creature_tier_price
	creature_tier_price *= 30
	if creature_tier_price > 500:
		creature_tier_price = 9223372036854775807
		better_creatures_button.visible = false
	creature_tier += 1
	better_creatures_button.disabled = true

func handle_multi_but():
	print("purchased multiplier")
	money -= multi_price
	multi_price *= 10
	if multi_price > 1500:
		multi_price = 9223372036854775807
		multi_button.visible = false
	money_mult *= 2
	multi_button.disabled = true

func update_store():
	net_button.text = "Net Upgrade $%s" % net_price
	spawn_button.text = "More Creatures $%s" % spawn_price
	speed_button.text = "Movement $%s" % speed_price
	better_creatures_button.text = "Better Creatures $%s" % creature_tier_price
	multi_button.text = "Double Money $%s" % multi_price
	
	if net_price <= money:
		enable_button(net_button)
	else:
		net_button.disabled = true
	if spawn_price <= money:
		enable_button(spawn_button)
	else:
		spawn_button.disabled = true
	if speed_price <= money:
		enable_button(speed_button)
	else:
		speed_button.disabled = true
	if creature_tier_price <= money:
		enable_button(better_creatures_button)
	else:
		better_creatures_button.disabled = true
	if multi_price <= money:
		enable_button(multi_button)
	else:
		multi_button.disabled = true


func enable_button(button: Button) -> void:
	button.visible = true
	button.disabled = false
