extends Spatial

enum{OVERWORLD, BATTLE}

onready var active : int = OVERWORLD;

onready var overworld : Spatial = $Overworld;
onready var battle : Spatial = $Battle;

func _ready():
	Global.current_level_controller = self;

func _show_battle():
	if (active != BATTLE):
		overworld.visible = false;
		battle.visible = true;
		active = BATTLE;

func _show_overworld():
	if (active != OVERWORLD):
		overworld.visible = true;
		battle.visible = false;
		active = OVERWORLD;
