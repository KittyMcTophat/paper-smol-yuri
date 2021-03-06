extends WorldEnvironment

class_name LevelController

enum {NONE, OVERWORLD, BATTLE}

export(int, "None", "Overworld", "Battle") var default_active : int = OVERWORLD;

export var overworld_music : AudioStream = null;
export var battle_music : AudioStream = null;

var active : int = -1;

onready var overworld : Spatial = $Overworld;
onready var battle : BattleController = $Battle;
onready var fade_rect_anim_player : AnimationPlayer = $CanvasLayer/ColorRect/AnimationPlayer;

func _ready():
	Global.current_level_controller = self;
	
	overworld.visible = true;
	battle.visible = true;
	$Skybox.visible = true;
	
	yield(get_tree(), "idle_frame");
	yield(get_tree(), "idle_frame");
	
	match default_active:
		NONE:
			enable_none();
		OVERWORLD:
			enable_overworld();
		BATTLE:
			enable_battle();

func _notification(what : int):
	if (what == NOTIFICATION_PREDELETE):
		if (is_instance_valid(overworld)):
			overworld.queue_free();
		if (is_instance_valid(battle)):
			battle.queue_free();

func enable_none():
	if (active != NONE):
		_disable(overworld);
		_disable(battle);
		active = NONE;

func enable_overworld():
	if (active != OVERWORLD):
		enable_none();
		_enable(overworld);
		active = OVERWORLD;
		Global.coin_counter.modulate = Color.white;
		MusicManager.change_music(overworld_music);

func enable_battle():
	if (active != BATTLE):
		enable_none();
		_enable(battle);
		active = BATTLE;
		Global.coin_counter.modulate = Color.transparent;
		#MusicManager.change_music(battle_music);

func _enable(node : Node):
	if (is_a_parent_of(node)):
		return;
	add_child(node);

func _disable(node : Node):
	if (is_a_parent_of(node)):
		remove_child(node);
	return;
