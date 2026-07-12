extends Control

var resources_path = "res://RESOURCES/UI_SPRITES/ACTION_TRACKER_UI/"
var action_button_sprite_scene = load("res://ESCENAS/action_button_sprite.tscn")
@onready var timer: Timer = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.action_press_signal.connect(on_action_press_signal)
	timer.wait_time = GlobalController.combat_timer_value
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)


	GlobalController.start_attack_sequence_signal.connect(on_start_attack_sequence_signal)
	GlobalController.restart_action_tracker_signal.connect((on_restart_action_tracker_signal))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TextureProgressBar.value = abs(1 - timer.time_left)


func on_action_press_signal(action_name : String) -> void:
	var sprite2D = action_button_sprite_scene.instantiate()
	match (action_name):
		"action_a":			
			sprite2D.texture = load(resources_path + "360_A.png")
		"action_b":			
			sprite2D.texture = load(resources_path + "360_B.png")
		"action_x":			
			sprite2D.texture = load(resources_path + "360_X.png")
		
	#$HBoxActionTracker.add_child(sprite2D)
	sprite2D.position = $ActionMarker.position
	add_child(sprite2D)
	#animacion por aqui no creen?


func _on_timeout() -> void:
	$TextureProgressBar.visible = false


func on_start_attack_sequence_signal() -> void:
	timer.start()
	$TextureProgressBar.visible = true
	$ActionMarker/AnimationPlayer.play("slide")
	# mas mierda más adelante


func on_restart_action_tracker_signal() -> void:
	for action in get_tree().get_nodes_in_group("actions_UI"):
		action.queue_free()
