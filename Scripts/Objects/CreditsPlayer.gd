extends Node

signal credits_are_over

func emit_credits_are_over():
	emit_signal("credits_are_over");

func _roll_credits():
	#warning-ignore:RETURN_VALUE_DISCARDED
	Global.credits.connect("credits_over", self, "emit_credits_are_over");
	Global.credits._roll_credits();
