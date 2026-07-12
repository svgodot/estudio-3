extends Node

@onready var timer: Timer = Timer.new()
@onready var single_button_timer : Timer = Timer.new()
var last_time = 0

@export var umbral_consecutivo = 0.25
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = GlobalController.combat_timer_value
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)

	single_button_timer.wait_time = 1
	single_button_timer.one_shot = true
	
	add_child(single_button_timer)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if (GlobalController.can_smash_actions):
		if (event.is_action_pressed("action_a")):
			start_timer("a")
			GlobalController.action_press_signal.emit("action_a")
			GlobalController.button_array.append("a")
			GlobalController.play_mask_animation.emit("a")
		elif (event.is_action_pressed("action_b")):
			start_timer("b")
			GlobalController.action_press_signal.emit("action_b")
			GlobalController.button_array.append("b")
			GlobalController.play_mask_animation.emit("b")
		elif (event.is_action_pressed("action_x")):
			start_timer("x")
			GlobalController.action_press_signal.emit("action_x")
			GlobalController.button_array.append("x")
			GlobalController.play_mask_animation.emit("x")
	else:
		if(event.is_action_pressed("repeat")):
			GlobalController.can_smash_actions = true
			GlobalController.restart_action_tracker_signal.emit()


func start_timer(btn_name : String) -> void:
	if (timer.is_stopped()):
		GlobalController.button_array.clear()
		timer.start()
		GlobalController.start_attack_sequence_signal.emit()
		GlobalController.array_dict_button_time.append({btn_name : 0})
		single_button_timer.start()
	else:
		GlobalController.array_dict_button_time.append({btn_name : single_button_timer.wait_time - single_button_timer.time_left})
		single_button_timer.stop()
		single_button_timer.start()
		


func resolve_action() -> void:
	# CALCULAR CUANTAS COSAS
	var number_of_actions = GlobalController.button_array.size()
	var total_array_string = ""
	for s in GlobalController.button_array:
		total_array_string += s

	var number_of_x = total_array_string.count("x",0,0)
	var number_of_b = total_array_string.count("b",0,0)
	var number_of_a = total_array_string.count("a",0,0)

	#print("TOTAL: ",number_of_actions)
	#print("Xs: ",number_of_x)
	#print("Bs: ",number_of_b)
	#print("As: ",number_of_a)

	#EXTRAER LOS TIEMPOS
	var media_seconds_between_actions = calculate_media_between_actions(GlobalController.array_dict_button_time)
	var is_there_too_many_consecutives = calculate_too_many_consecutives(GlobalController.array_dict_button_time)

	#print("MEDIA DE TIEMPOS: ", media_seconds_between_actions)
	#print("MUY CONSECUTIVO: ", is_there_too_many_consecutives)

	# RESOLVER



	# LIMPIAR 
	GlobalController.array_dict_button_time = []
	GlobalController.button_array = []

# Más del 50% de tiempos son consecutivos (ver umbral)
func calculate_too_many_consecutives(list_dict : Array) -> bool:
	var res = false
	var acc = 0
	var size = list_dict.size() - 1

	for pair in list_dict:
		for i in pair:
			var seconds = pair[i]
			if (seconds <= umbral_consecutivo && seconds != 0.0):
				acc += 1


	if (acc > (size/2)):
		res = true

	return res

func calculate_media_between_actions(list_dict : Array) -> float:
	var res = 0.0
	var size = list_dict.size() - 1
	#print(list_dict)
	#print(size)
	for pair in list_dict:
		for i in pair:
			var seconds = pair[i]
			if (seconds != 0.0):
				res += seconds


	return res / size


func _on_timeout() -> void:
	GlobalController.can_smash_actions = false
	resolve_action()
