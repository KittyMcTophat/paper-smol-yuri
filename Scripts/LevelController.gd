extends WorldEnvironment

class_name LevelController

enum {NONE, OVERWORLD, BATTLE}

export(int, "None", "Overworld", "Battle") var default_active : int = OVERWORLD;
export var background_texture : Texture = null;

var active : int = -1;

onready var overworld : Spatial = $Overworld;
onready var battle : BattleController = $Battle;
onready var fade_rect_anim_player : AnimationPlayer = $CanvasLayer2/ColorRect/AnimationPlayer;

func _ready():
	Global.current_level_controller = self;
	
	overworld.visible = true;
	battle.visible = true;
	
	if (background_texture != null):
		# converts to linear color to prevent a graphical error
		if (background_texture.flags & Texture.FLAG_CONVERT_TO_LINEAR):
			background_texture.flags += Texture.FLAG_CONVERT_TO_LINEAR;
		
		$CanvasLayer/TextureRect.texture = background_texture;
	
	environment = preload("res://level_env.tres");
	
	yield(get_tree(), "idle_frame");
	
	match default_active:
		NONE:
			enable_none();
		OVERWORLD:
			enable_overworld();
		BATTLE:
			enable_battle();

func _exit_tree():
	overworld.queue_free();
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

func enable_battle():
	if (active != BATTLE):
		enable_none();
		_enable(battle);
		active = BATTLE;

func _enable(node : Node):
	if (is_a_parent_of(node)):
		return;
	add_child(node);

func _disable(node : Node):
	if (is_a_parent_of(node)):
		remove_child(node);
	return;
