extends InteractableActor

export var cat_index : int = 0;

func _interact():
	Global.cats_found[cat_index] = true;
	._interact();
