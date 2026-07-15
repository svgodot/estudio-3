extends Control

var last_score = 0
var last_action = 0 
# criminal esto
# they can't keep getting away with it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalController.do_damage_signal.connect(on_do_damage_signal)
	GlobalController.npc_attack_feedback_signal.connect(on_npc_attack_feedback_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_do_damage_signal (score: int) -> void:
	$Panel/Panel/TextureRect/AnimationPlayer.play("damage")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "damage"):
		GlobalController.new_turn_signal.emit(false)		## PARA PROBASR. CAMBIALO A FALSE LUEGO.
	elif (anim_name == "attack"):
		GlobalController.npc_do_damage_signal.emit(last_score, last_action)


func  on_npc_attack_feedback_signal(score: int, action: int) -> void:
	$Panel/Panel/TextureRect/AnimationPlayer.play("attack")
	last_score = score
	last_action = action