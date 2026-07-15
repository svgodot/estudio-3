class_name ChoiceTurn
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FightBtn.pressed.connect(on_fight_pressed)
	$TalkBtn.pressed.connect(on_talk_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("right_trigger")):
		$FightBtn.pressed.emit()
	elif (event.is_action_pressed("left_trigger")):
		$TalkBtn.pressed.emit()


func on_fight_pressed() -> void:
	$FightBtn/AnimationPlayer.play("press")
	GlobalController.select_fight_signal.emit()

func on_talk_pressed() -> void:
	$TalkBtn/AnimationPlayer.play("press")
	GlobalController.select_talk_signal.emit()
	
