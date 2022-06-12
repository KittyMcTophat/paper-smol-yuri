extends Node

export(Array, String, MULTILINE) var dialogues : Array = [];

func turn_ended(turn_number : int):
	if (turn_number > dialogues.size() - 1):
		return;
	if (dialogues[turn_number] == ""):
		return;
	Global.dialogue_box.start_dialogue(parse_json(dialogues[turn_number]), null);
