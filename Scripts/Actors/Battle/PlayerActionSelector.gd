extends Spatial

signal action_over
signal turn_over

# target types for actions
enum State {INACTIVE, ACTION_SELECT, TARGET_SELECT}

onready var _anim_player : AnimationPlayer = $AnimationPlayer;
onready var _sprite3d : Sprite3D = $Sprite3D;
onready var _player : Node = get_parent();

export(Array, PackedScene) var action_scenes : Array = [];

var selected_action : int = 0;
var selected_target : int = 0;
var state : int = State.INACTIVE;
var actions : Array = [];
var potential_targets : Array = [];

func _enter_tree() -> void:
	if (actions.size() == 0):
		_add_actions(action_scenes);

func _add_actions(new_actions : Array) -> void:
	if (new_actions.size() == 0):
		print("No actions, Gromit!");
		return;
	
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
	
	state = State.ACTION_SELECT;
	
	yield(self, "action_over");
	
	state = State.INACTIVE;
	
	emit_signal("turn_over");

func _process(_delta) -> void:
	if (state == State.INACTIVE):
		return;
	
	if (state == State.ACTION_SELECT):
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
					potential_targets = [];
					
					match actions[selected_action].target_type:
						PlayerAction.TargetType.SELF:
							potential_targets.push_back(_player);
						PlayerAction.TargetType.ENEMY:
							for e in Global.current_level_controller.battle._enemies:
								if (is_instance_valid(e) && e.current_health > 0):
									potential_targets.push_back(e);
						PlayerAction.TargetType.PLAYER:
							for p in Global.current_level_controller.battle._players:
								if (is_instance_valid(p) && p.current_health > 0):
									potential_targets.push_back(p)
					
					_anim_player.play("Hide");
					state = State.TARGET_SELECT;
					selected_target = 0;
					potential_targets[selected_target].selector_arrow.visible = true;
					return;
	
	if (state == State.TARGET_SELECT):
		if (Input.is_action_just_pressed("ui_left")):
			potential_targets[selected_target].selector_arrow.visible = false;
			
			selected_target -= 1;
			if (selected_target < 0):
				selected_target = potential_targets.size() - 1;
			
			potential_targets[selected_target].selector_arrow.visible = true;
		else:
			if (Input.is_action_just_pressed("ui_right")):
				potential_targets[selected_target].selector_arrow.visible = false;
				
				selected_target += 1;
				selected_target = selected_target % potential_targets.size();
				
				potential_targets[selected_target].selector_arrow.visible = true;
			else:
				if (Input.is_action_just_pressed("ui_accept")):
					potential_targets[selected_target].selector_arrow.visible = false;
					
					actions[selected_action]._execute_action(_player, potential_targets[selected_target]);
					yield(actions[selected_action], "action_over");
					emit_signal("action_over");
				else:
					if (Input.is_action_just_pressed("ui_cancel")):
						potential_targets[selected_target].selector_arrow.visible = false;
						
						_anim_player.play("Show");
						
						state = State.ACTION_SELECT;
