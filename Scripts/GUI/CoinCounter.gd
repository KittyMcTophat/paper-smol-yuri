extends Control

class_name CoinCounter

var money : int = 0;

onready var _label : Label = $CenterContainer/MarginContainer/PanelContainer/MarginContainer/Label;

func _ready():
	_update_label();

func set_money(num_cents : int = 0) -> void:
	money = num_cents;
	_update_label();

func get_money() -> int:
	return money;

func add_money(num_cents : int = 25) -> void:
	money += num_cents;
	_update_label();

func _update_label() -> void:
	var money_as_string : String = "";
	
	if (money % 100 >= 10):
#warning-ignore:INTEGER_DIVISION
		money_as_string = "$" + str(money / 100) + "." + str(money % 100);
	else:
#warning-ignore:INTEGER_DIVISION
		money_as_string = "$" + str(money / 100) + ".0" + str(money % 100);
	
	_label.text = money_as_string;
	pass;
