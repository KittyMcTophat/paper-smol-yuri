extends Control

class_name PlayerAction

signal action_over

onready var selector_arrow : TextureRect = $HBoxContainer/SelectorArrow;

enum{SELF, PLAYER, ENEMY}
export(int, "SELF", "PLAYER", "ENEMY") var target_type : int = ENEMY;

func _execute_action(_player : Node, _target : Node):
	yield(get_tree().create_timer(0.1), "timeout");
	emit_signal("action_over");
