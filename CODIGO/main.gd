extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.play_mask_animation.connect(on_play_mask_animation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_play_mask_animation(action : String) -> void:
	if (!GlobalController.is_talking):
		$Mask1/Mask1AnimationPlayer.stop()
		$Mask1/Mask1AnimationPlayer.play(action)
