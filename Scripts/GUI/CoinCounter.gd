extends Control

onready var _label : Label = $Label;

func _ready():
	Global.add_money = funcref(self, "add_money");
	_update_label();

func set_money(num_cents : int = 0) -> void:
	Global.money = num_cents;
	_update_label();

func add_money(num_cents : int = 25) -> void:
	Global.money += num_cents;
	_update_label();

func _update_label() -> void:
	var money_as_string : String = "";
	
	if (Global.money % 100 >= 10):
#warning-ignore:INTEGER_DIVISION
		money_as_string = "$" + str(Global.money / 100) + "." + str(Global.money % 100);
	else:
#warning-ignore:INTEGER_DIVISION
		money_as_string = "$" + str(Global.money / 100) + ".0" + str(Global.money % 100);
	
	_label.text = money_as_string;
	pass;
