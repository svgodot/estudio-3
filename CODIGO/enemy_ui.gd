extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.do_damage_signal.connect(on_do_damage_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_do_damage_signal (score: int) -> void:
	$Panel/Panel/TextureRect/AnimationPlayer.play("damage")