extends BattleActor

class_name Enemy

onready var attack_anim_player : AnimationPlayer = $Attacks;

export(Array, String) var attack_animations : Array = [];

func _do_your_turn() -> void:
	if (attack_animations.size() == 0):
		print("No attacks, Gromit!");
		_end_turn();
		return;
	
	var attack : int = randi() % attack_animations.size();
	
	attack_anim_player.play(attack_animations[attack]);
	attack_anim_player.advance(0);
	
	yield(attack_anim_player, "animation_finished");
	yield(get_tree().create_timer(1.0), "timeout");
	
	var projectiles_gone : bool = false;
	while (!projectiles_gone):
		yield(get_tree().create_timer(0.1), "timeout");
		projectiles_gone = Global.current_level_controller.battle.are_projectiles_gone();
	
	yield(get_tree().create_timer(0.5), "timeout");
	
	_end_turn();

func _end_turn():
	emit_signal("turn_over");

func _kill() -> void:
	yield(get_tree().create_timer(0.4), "timeout");
	queue_free();

func _shoot():
	_fire_projectile(target_direction, attack);

func _jump_shoot():
	_jump_and_fire_projectile(jump_strength, target_direction, attack);
