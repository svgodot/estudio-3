extends Node

# Bienvenido de nuevo.
var button_array = []
var array_dict_button_time = []  # {["a",0.2]} -> Botón A pulsado 0.2 segundos después de anterior posición. -1 es primera posición.
var is_mc_turn = false
var can_smash_actions = true
var is_talking = false
@export var combat_timer_value = 1

signal action_press_signal(action_name)
signal start_attack_sequence_signal()
signal restart_action_tracker_signal()
signal play_mask_animation(action_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
