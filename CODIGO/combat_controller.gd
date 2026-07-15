extends Node

@onready var timer: Timer = Timer.new()
@onready var single_button_timer : Timer = Timer.new()
var last_time = 0

@export var umbral_consecutivo = 0.25

@export var combat_resources: ResourceCombat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = GlobalController.combat_timer_value
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)

	single_button_timer.wait_time = 1
	single_button_timer.one_shot = true
	
	add_child(single_button_timer)

	GlobalController.resolve_npc_action_signal.connect(on_resolve_npc_action)


	

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
		

func on_resolve_npc_action() -> void:
	var turn = GlobalController.turn_cont
	var sequence = combat_resources.attack_pattern

	var turn_mod = turn % sequence.size()
	var action = sequence[turn_mod]
	var action_type = -1

	var score = combat_resources.enemy_attack

	# a -> joy, b -> anger, c -> sorrow, x -> wildcard
	match (action):
		"a":
			score += combat_resources.npc_joy_mod
			action_type = 0
		"b":
			score += combat_resources.npc_anger_mod
			action_type = 1
		"c":
			score += combat_resources.npc_sorrow_mod
			action_type = 2
		"x":
			score += combat_resources.npc_wildcard_mod
			action_type = -1


	GlobalController.npc_attack_feedback_signal.emit(score,action_type)
	



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

	# GUESS EMOTION
	var number_of_array = [number_of_a, number_of_b, number_of_x]
	var cont = 0
	var is_anger = false
	var is_joy = false
	var is_sorrow = false
	var action_score = 0
	var action = 0
	

	for i in number_of_array:
		if (i != 0):
			cont += 1
	
	match (cont):
		0:
			pass
		1:
			is_sorrow = true
			is_anger = true
		2:
			is_joy = true
			is_sorrow = true
		3: 
			is_joy = true
			is_sorrow = true

	print (media_seconds_between_actions)
	if (media_seconds_between_actions < 0.25):
		is_sorrow = false

	if (is_sorrow):
		action_score = combat_resources.player_attack + combat_resources.sorrow_mod
		action = 2
	elif (is_anger):
		action_score = combat_resources.player_attack + combat_resources.anger_mod
		action = 1
	elif (is_joy):
		action_score = combat_resources.player_attack + combat_resources.joy_mod
		action = 0


	if (!GlobalController.is_talking):
		GlobalController.show_action_signal.emit(action_score, action) # 0 joy, 1 anger, 2 sorrow
	else:
		pass
		# TODO

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
