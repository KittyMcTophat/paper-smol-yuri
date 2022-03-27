extends Spatial

enum{NONE, OVERWORLD, BATTLE}

onready var active : int = OVERWORLD;

onready var overworld : Spatial = $Overworld;
onready var battle : Spatial = $Battle;
onready var fade_rect_anim_player : AnimationPlayer = $ColorRect/AnimationPlayer;

func _ready():
	Global.current_level_controller = self;

func _show_none():
	if (active != NONE):
		overworld.visible = false;
		battle.visible = false;
		active = NONE;

func _show_overworld():
	if (active != OVERWORLD):
		overworld.visible = true;
		battle.visible = false;
		active = OVERWORLD;

func _show_battle():
	if (active != BATTLE):
		overworld.visible = false;
		battle.visible = true;
		active = BATTLE;
