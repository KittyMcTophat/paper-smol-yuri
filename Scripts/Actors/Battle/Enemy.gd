extends BattleActor

class_name Enemy

export(Array, String) var attack_animations : Array = [];

func _do_your_turn() -> void:
	emit_signal("turn_over");
	return;

func _kill() -> void:
	# https://www.youtube.com/watch?v=iVGVXPuO3xQ
	print("No health, gromit!");
