extends Control

class_name PlayerAction

signal action_over

onready var selector_arrow : TextureRect = $HBoxContainer/SelectorArrow;

enum{SELF, PLAYER, ENEMY, ALL_PLAYERS, ALL_ENEMIES}
export(int, "SELF", "PLAYER", "ENEMY", "ALL PLAYERS", "ALL ENEMIES") var target_type : int = ENEMY;

func _execute_action(_player : Node, _targets : Array):
	yield(get_tree().create_timer(0.1), "timeout");
	emit_signal("action_over");
