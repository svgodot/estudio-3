extends Node

# Bienvenido de nuevo.
var button_array = []
var is_mc_turn = false
var can_smash_actions = true
@export var combat_timer_value = 1

signal action_press_signal(action_name)
signal start_attack_sequence_signal()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
