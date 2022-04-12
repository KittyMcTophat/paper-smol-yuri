extends Spatial

signal action_over
signal turn_over

onready var _anim_player : AnimationPlayer = $AnimationPlayer;
onready var _sprite3d : Sprite3D = $Sprite3D;
onready var _player : Node = get_parent();

export(Array, PackedScene) var action_scenes : Array = [];

var enabled : bool = false;
var selected_action : int = 0;
var actions : Array = [];

func _enter_tree() -> void:
	if (actions.size() == 0):
		_add_actions(action_scenes);

func _add_actions(new_actions : Array) -> void:
	if (new_actions.size() == 0):
		print("No actions, Gromit!");
		return;
	print("adding actions")
	
	var vbox : VBoxContainer = $Viewport/Control/NinePatchRect/MarginContainer/VBoxContainer;
	for action in new_actions:
		var instance = action.instance();
		vbox.add_child(instance);
		actions.push_back(instance);
	
	yield(get_tree(), "idle_frame");
	
	selected_action = 0;
	actions[selected_action].selector_arrow.visible = true;
	
	$Viewport.size = $Viewport/Control/NinePatchRect/MarginContainer.rect_size;
	_sprite3d.offset.y = $Viewport.size.y / 2.0;

func _pick_action() -> void:
	_anim_player.play("Show");
	
	yield(_anim_player, "animation_finished");
	
	enabled = true;
	
	yield(self, "action_over");
	
	enabled = false;
	
	_anim_player.play("Hide");
	
	yield(_anim_player, "animation_finished");
	
	emit_signal("turn_over");

func _process(_delta) -> void:
	if (!enabled):
		return;
	
	if (Input.is_action_just_pressed("ui_up")):
		actions[selected_action].selector_arrow.visible = false;
		
		selected_action -= 1;
		if (selected_action < 0):
			selected_action = actions.size() - 1;
		
		actions[selected_action].selector_arrow.visible = true;
	else:
		if (Input.is_action_just_pressed("ui_down")):
			actions[selected_action].selector_arrow.visible = false;
			
			selected_action += 1;
			selected_action = selected_action % actions.size();
			
			actions[selected_action].selector_arrow.visible = true;
		else:
			if (Input.is_action_just_pressed("ui_accept")):
				actions[selected_action]._execute_action(_player, []);
				emit_signal("action_over");
