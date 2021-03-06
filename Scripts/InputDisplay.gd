extends Node

export var is_keyboard : bool = true;

func _ready():
	_update_visibility();
	
# warning-ignore:return_value_discarded
	Global.connect("controller_state_changed", self, "_update_visibility");

func _update_visibility():
	self.visible = Global.controller_connected != is_keyboard;
