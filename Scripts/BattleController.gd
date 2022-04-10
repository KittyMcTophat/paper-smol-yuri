extends Spatial

signal battle_start
signal battle_start_early
signal battle_end
signal battle_end_early

class_name BattleController

export var player_separation : float = 1.0;
export var enemy_separation : float = -1.0;

export var first_player_position : Vector3 = Vector3(-4.5, 0.0, 0.0);
export var first_enemy_position : Vector3 = Vector3(4.5, 0.0, 0.0);

onready var _camera : Camera = $Camera;
onready var _level_controller : WorldEnvironment = get_parent();
onready var _players_container : Spatial = $PlayersContainer;
onready var _enemies_container : Spatial = $EnemiesContainer;

func start_battle(players : Array = [], enemies : Array = []):
	Global.allow_pause = false;
	Global.allow_jump = false;
	Global.get_tree().paused = true;
	
	_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");
	
	_level_controller.enable_battle();
	
	for i in range(players.size()):
		_players_container.add_child(players[i]);
		players[i].transform.origin = first_player_position;
		players[i].transform.origin.x += player_separation * i;
	
	for i in range(enemies.size()):
		_enemies_container.add_child(enemies[i]);
		enemies[i].transform.origin = first_enemy_position;
		enemies[i].transform.origin.x += enemy_separation * i;
	
	emit_signal("battle_start_early");
	
	_level_controller.fade_rect_anim_player.play("Fade_Out");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");	
	
	Global.allow_pause = true;
	Global.allow_jump = true;
	Global.get_tree().paused = false;
	
	emit_signal("battle_start");

func end_battle():
	Global.allow_pause = false;
	Global.allow_jump = false;
	Global.get_tree().paused = true;
	
	_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");
	
	_level_controller.enable_overworld();
	
	for child in _players_container.get_children():
		if (child is Projectile):
			child.queue_free();
		else:
			_players_container.remove_child(child);
	
	for child in _enemies_container.get_children():
		if (child is Projectile):
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