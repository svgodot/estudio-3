class_name ResourceCombat
extends Resource

@export var player_attack:int
@export var player_defense:int
@export var player_health:int
@export var enemy_attack:int
@export var enemy_defense:int
@export var enemy_health:int

@export var sorrow_mod:int
@export var joy_mod:int
@export var anger_mod:int

@export var npc_sorrow_mod:int
@export var npc_joy_mod:int
@export var npc_anger_mod:int
@export var npc_wildcard_mod:int

@export var attack_pattern:Array

func _init(p_attack = 0, p_defense = 0, p_health = 0, e_attack = 0, e_defense = 0,
			 e_health = 0, sorrow = 0, joy = 0, anger = 0, npc_sorrow = 0, npc_anger = 0, npc_joy = 0, npc_wildcard = 0,
			  pattern = []):	
	player_attack = p_attack
	player_defense = p_defense
	player_health = p_health
	enemy_attack = e_attack
	enemy_defense = e_defense
	enemy_health = e_health	
	
	sorrow_mod = sorrow
	joy_mod = joy
	anger_mod = anger	
	npc_joy = npc_joy_mod
	npc_anger = npc_anger_mod
	npc_sorrow = npc_sorrow_mod
	npc_wildcard = npc_wildcard_mod

	attack_pattern = pattern
	