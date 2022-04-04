extends InteractableActor

class_name SmolYurisSmolCat

var _was_found : bool = false;

func _interact():
	if (!_was_found):
		_was_found = true;
	#warning-ignore:RETURN_VALUE_DISCARDED
		Global.connect("scene_is_changing", self, "_update_cat_number");
	._interact();

func _update_cat_number():
	Global.cats_found += 1;