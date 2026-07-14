extends Control

@onready var timer: Timer = Timer.new()
var last_score_value = 0
@export var label_settings:LabelSettings
var damageLabelTween:Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.play_mask_animation.connect(on_play_mask_animation)
	GlobalController.show_action_signal.connect(on_show_action_signal)

	timer.wait_time = 1.5
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)

	add_child(timer)


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

	$ActionText.visible = true
	$ColorRect.visible = true

	$ActionText/AnimationPlayer.play("fade")
	$ColorRect/AnimationPlayer.play("fade")

	last_score_value = value
	timer.start()
	

	

func _on_timeout() -> void:
	do_damage(last_score_value)


func do_damage(score: int) -> void:
	$EnemyStatsUI/Panel/HealthBar.value -= score
	GlobalController.do_damage_signal.emit(score)
	var str = String.num(score)
	add_floating_label(str, $Marker2D.global_position)


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
