extends Spatial

class_name BattleController

onready var _camera : Camera = $Camera;
onready var _level_controller : WorldEnvironment = get_parent();

func start_battle(players : Array = [], enemies : Array = []):
	Global.allow_pause = false;
	Global.allow_jump = false;
	Global.get_tree().paused = true;
	
	_level_controller.fade_rect_anim_player.play("Fade_In");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");
	
	_level_controller.enable_battle();
	
	_level_controller.fade_rect_anim_player.play("Fade_Out");
	yield(_level_controller.fade_rect_anim_player, "animation_finished");	
	
	Global.allow_pause = true;
	Global.allow_jump = true;
	Global.get_tree().paused = false;
