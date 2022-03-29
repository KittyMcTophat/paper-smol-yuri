extends "res://Scripts/Actors/Battle/BattleActor.gd"


export(Array, Array, String) var attack_animations : Array = [];

func _do_your_turn() -> void:
	emit_signal("turn_over");
	return;

func _kill() -> void:
	return;

func _fire_projectile(_direction : Vector3 = Vector3.LEFT):
	return;
