extends Node

@onready var timer: Timer = Timer.new()
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = GlobalController.combat_timer_value
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if (GlobalController.can_smash_actions):
		if (event.is_action_pressed("action_a")):
			start_timer()
			GlobalController.action_press_signal.emit("action_a")
			GlobalController.button_array.append("a")
		elif (event.is_action_pressed("action_b")):
			start_timer()
			GlobalController.action_press_signal.emit("action_b")
			GlobalController.button_array.append("b")
		elif (event.is_action_pressed("action_x")):
			start_timer()
			GlobalController.action_press_signal.emit("action_x")
			GlobalController.button_array.append("x")


func start_timer() -> void:
	if (timer.is_stopped()):
		GlobalController.button_array.clear()
		timer.start()
		GlobalController.start_attack_sequence_signal.emit()


func resolve_action() -> void:
	# CALCULAR CUANTAS COSAS
	var number_of_actions = GlobalController.button_array.size()
	var total_array_string = ""
	for s in GlobalController.button_array:
		total_array_string += s

	var number_of_x = total_array_string.count("x",0,0)
	var number_of_b = total_array_string.count("b",0,0)
	var number_of_a = total_array_string.count("a",0,0)

	print("TOTAL: ",number_of_actions)
	print("Xs: ",number_of_x)
	print("Bs: ",number_of_b)
	print("As: ",number_of_a)


	# RESOLVER
	


func _on_timeout() -> void:
	GlobalController.can_smash_actions = false
	resolve_action()