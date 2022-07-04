extends Spatial

signal battle_start
signal battle_start_early
signal battle_end
signal battle_end_early
signal turn_ended(turn_number)

class_name BattleController

export var player_separation : float = 1.0;
export var enemy_separation : float = -1.0;

export var first_player_position : Vector3 = Vector3(-4.0, 0.0, 0.0);
export var first_enemy_position : Vector3 = Vector3(4.0, 0.0, 0.0);

onready var _camera : Camera = $Camera;
onready var _level_controller : WorldEnvironment = get_parent();
onready var _players_container : Spatial = $PlayersContainer;
onready var _enemies_container : Spatial = $EnemiesContainer;

var _players : Array = [];
var _enemies : Array = [];
var _battle_is_active : bool = false;
var _turn_number : int = 0;

func start_battle(players : Array = [], enemies : Array = []):
	Global.allow_pause = false;
	Global.allow_jump = false;
	Global.get_tree().paused = true;
	
	_battle_is_active = true;
	_turn_number = 0;
	print("Starting battle with:");
	for enemy in enemies:
		print(enemy.actor_name.replace("\n"," "));
	
	_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");
	
	_level_controller.enable_battle();
	
	for icon in $PlayerKeyHints/Keyboard.get_children():
		icon.visible = false;
	
	for icon in $PlayerKeyHints/Controller.get_children():
		icon.visible = false;
	
	for i in range(players.size()):
		_players_container.add_child(players[i]);
		players[i].transform.origin = first_player_position;
		players[i].transform.origin.x += player_separation * i;
		$PlayerKeyHints/Keyboard.get_child(i).visible = true;
		$PlayerKeyHints/Controller.get_child(i).visible = true;
		players[i]._enter_battle();
	
	enemies.invert();
	
	for i in range(enemies.size()):
		_enemies_container.add_child(enemies[i]);
		enemies[i].transform.origin = first_enemy_position;
		enemies[i].transform.origin.x += enemy_separation * i;
		enemies[i]._enter_battle();
	
	_players = players;
	_enemies = enemies;
	_enemies.invert();
	
	emit_signal("battle_start_early");
	
	_level_controller.fade_rect_anim_player.play("Fade_Out");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");	
	
	Global.allow_jump = true;
	Global.get_tree().paused = false;
	
	emit_signal("battle_start");
	
	main_battle_loop();

func main_battle_loop():
	var is_battle_over : bool = false;
	
	while (!is_battle_over):
		Global.allow_pause = true;
		
		#player turns
		for player in _players:
			player.enable_jump = false;
		
		for player in _players:
			is_battle_over = check_if_battle_over();
			if (is_battle_over):
				break;
			if (all_players_dead()):
				is_battle_over = true;
				break;
			if player.current_health > 0:
				player._do_your_turn();
				yield(player, "turn_over");
		
		for player in _players:
			player.enable_jump = true;
		
		Global.allow_pause = false;
		
		# enemy turns
		for enemy in _enemies:
			is_battle_over = check_if_battle_over();
			if (is_battle_over):
				break;
			if (all_players_dead()):
				is_battle_over = true;
				break;
			
			if (is_instance_valid(enemy)):
				if (enemy.current_health == 0):
					continue;
				enemy._do_your_turn();
				yield(enemy, "turn_over");
		
		emit_signal("turn_ended", _turn_number);
		_turn_number += 1;
	
	if (all_players_dead()):
		return;
	
	# Waits for all enemies to finish their death animations
	var all_enemies_dead : bool = true;
	while true:
		for enemy in _enemies:
			if (is_instance_valid(enemy)):
				all_enemies_dead = false;
		
		if (!all_enemies_dead):
			all_enemies_dead = true;
			yield(get_tree(), "idle_frame");
		else:
			break;
	
	end_battle();

func all_players_dead() -> bool:
	for player in _players:
		if (player.current_health > 0):
			return false;
	
	return true;

func check_if_battle_over() -> bool:
	for enemy in _enemies:
		if (is_instance_valid(enemy) && enemy is BattleActor):
			if (enemy.current_health > 0):
				return false;
	
	return true;

func are_projectiles_gone() -> bool:
	for child in _enemies_container.get_children():
		if child is Projectile:
			return false;

	for child in _players_container.get_children():
		if child is Projectile:
			return false;
	
	return true;

func end_battle():
	Global.allow_jump = false;
	Global.get_tree().paused = true;
	
	_battle_is_active = false;
	
	_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");
	
	_level_controller.enable_overworld();
	
	for child in _players_container.get_children():
		if (!child is BattleActor):
			child.queue_free();
		else:
			_players_container.remove_child(child);
	
	for child in _enemies_container.get_children():
		if (!child is BattleActor):
			child.queue_free();
		else:
			_enemies_container.remove_child(child);
	
	emit_signal("battle_end_early");
	
	_level_controller.fade_rect_anim_player.play("Fade_Out");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");	
	
	Global.allow_pause = true;
	Global.allow_jump = true;
	Global.get_tree().paused = false;
	
	emit_signal("battle_end");
