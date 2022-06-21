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
	print("Using attack: " + attack_animations[attack]);
	
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
	_healthbar.queue_free();
	
	var rigidbody : RigidBody = RigidBody.new();
	get_parent().add_child(rigidbody);
	rigidbody.global_transform.origin = self.global_transform.origin
	
	while get_child_count() > 0:
		var child : Node = get_child(0);
		remove_child(child);
		rigidbody.add_child(child);
	
	var random_direction : Vector2 = Vector2(randf() - 0.5, randf() - 0.5);
	random_direction = random_direction.normalized();
	
	rigidbody.angular_velocity.y = 0.0;
	rigidbody.angular_velocity.x = random_direction.x * 7.5;
	rigidbody.angular_velocity.z = random_direction.y * 7.5;
	
	rigidbody.linear_velocity.y = 6.0;
	rigidbody.linear_velocity.x = random_direction.y * -1.5;
	rigidbody.linear_velocity.z = random_direction.x * 1.5;
	
	yield(get_tree().create_timer(3.0), "timeout");
	
	queue_free();

func _shoot():
	_fire_projectile(default_projectile, target_direction, attack);

func _jump_shoot():
	_jump_and_fire_projectile(jump_strength, default_projectile, target_direction, attack);
