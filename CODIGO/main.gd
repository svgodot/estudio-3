extends Control

@onready var timer: Timer = Timer.new()	# espera a que la animación de score label termine para hacer el ataque
@onready var between_turns_timer:Timer = Timer.new()
var last_score_value = 0
@export var label_settings:LabelSettings
var damageLabelTween:Tween

var choice_turn_scene = load("res://ESCENAS/choice_turn.tscn")

var last_action = 999

@export var wait_time_between_turns = 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.play_mask_animation.connect(on_play_mask_animation)
	GlobalController.show_action_signal.connect(on_show_action_signal)
	GlobalController.new_turn_signal.connect(on_new_turn_signal)
	GlobalController.select_fight_signal.connect(on_select_fight_signal)
	GlobalController.select_talk_signal.connect(on_select_talk_signal)
	GlobalController.npc_do_damage_signal.connect(on_npc_do_damage_signal)

	timer.wait_time = 1.5
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)

	between_turns_timer.wait_time = wait_time_between_turns
	between_turns_timer.one_shot = true
	between_turns_timer.timeout.connect(_on_between_turns_timeout)
	add_child(between_turns_timer)

	GlobalController.new_turn_signal.emit(true)
	GlobalController.turn_cont = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_play_mask_animation(action : String) -> void:
	if (!GlobalController.is_talking):
		$Mask1/Mask1AnimationPlayer.stop()
		$Mask1/Mask1AnimationPlayer.play(action)

func on_show_action_signal(value: int, action: int) -> void:
	match (action):
		0:
			$ActionText.text = "[shake rate=20.0 level=5 connected=1][color=yellow]JOY[/color][/shake]"
		1:
			$ActionText.text = "[shake rate=20.0 level=5 connected=1][color=red]ANGER[/color][/shake]"
		2:
			$ActionText.text = "[shake rate=20.0 level=5 connected=1][color=web_gray]SORROW[/color][/shake]"

	last_action = action

	$ActionText.visible = true
	$ColorRect.visible = true

	$Mask1.visible = false
	$ActionText/AnimationPlayer.play("fade")
	#$ColorRect/AnimationPlayer.play("fade")

	last_score_value = value
	timer.start()
	


func _on_timeout() -> void:
	match(last_action):
		2:
			do_damage(last_score_value)
		1:
			for i in range(5):
				do_damage(last_score_value/5)
		0:
			for i in range(3):
				do_damage(last_score_value/3)
				

func _on_between_turns_timeout() -> void:
	GlobalController.resolve_npc_action_signal.emit()
	set_previous_action_text() 	# revisar esta mecanica porque no convence.


func do_damage(score: int) -> void:
	$EnemyStatsUI/Panel/HealthBar.value -= score
	GlobalController.do_damage_signal.emit(score)	# animacion feedback
	var str = String.num(score)
	add_floating_label(str, $Marker2D.global_position)

	GlobalController.restart_action_tracker_signal.emit()


func add_floating_label(text: String, spawn_position:Vector2) -> void:
	var label = Label.new()
	label.text = text
	label.label_settings = label_settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 10
	label.top_level = true
	label.global_position = spawn_position
	label.global_position.x -= label.size.x/2.0
	label.global_position.y -= label.size.y
	add_child(label)

	if damageLabelTween and damageLabelTween.is_running():
		damageLabelTween.set_speed_scale(2.0)

	damageLabelTween = create_tween()
	damageLabelTween.set_parallel(true)

	var x = randf_range(-50,50)
	var y = -100.0

	damageLabelTween.tween_property(label, "position:x", x, 1.0).as_relative()

	damageLabelTween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	damageLabelTween.tween_property(label, "position:y", y, 1.0).as_relative()

	damageLabelTween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	damageLabelTween.tween_property(label, "modulate", Color.RED, 0.5).set_delay(0.5)
	damageLabelTween.tween_property(label, "self_modulate:a", 0.0, 0.2).set_delay(0.8)

	damageLabelTween.chain().tween_callback(label.queue_free)


func on_new_turn_signal(is_player : bool) -> void:
	GlobalController.turn_cont += 1
	if (is_player):
		GlobalController.can_smash_actions = false
		GlobalController.is_mc_turn = true

		var choice_turn:ChoiceTurn = choice_turn_scene.instantiate()
		add_child(choice_turn)
		set_previous_action_text()
		
	else:
		GlobalController.can_smash_actions = false
		GlobalController.is_mc_turn = false
		between_turns_timer.start()

func set_previous_action_text() -> void:
	var action = ""
	match (last_action):
		0:
			action = "JOY"
		1: 
			action = "ANGER"
		2:
			action = "SORROW"
		-1:
			action = "WILDCARD" # algo mas chulo habrá por ahí

	$PreviousActionText.text = "PRECEDES:[br] [shake rate=5.0 level=5 connected=1]"+action+"[/shake]"

func on_select_fight_signal() -> void:
	for ui in get_tree().get_nodes_in_group("choice_turn_UI"):
		ui.queue_free()
	
	# TODO: Cambiar sprite de mask1
	$Mask1.visible = true
	GlobalController.is_talking = false
	GlobalController.can_smash_actions = true


func on_select_talk_signal() -> void:
	for ui in get_tree().get_nodes_in_group("choice_turn_UI"):
		ui.queue_free()
	
	$Mask1.visible = true
	GlobalController.is_talking = true
	GlobalController.can_smash_actions = true


func on_npc_do_damage_signal(score:int,action:int) -> void:
	$PlayerStatsUI/Panel/HealthBar.value -= score
	var str = String.num(score)
	add_floating_label(str, $Marker2D2.global_position)
	last_action = action

	GlobalController.new_turn_signal.emit(true)