extends Spatial

class_name SmolCoin

signal coin_collected;

export var _value : int = 25;

func _on_Area_body_entered(_body):
	collect();

func collect():
	emit_signal("coin_collected");
	if (Global.coin_counter == null):
		print("Coin counter not found!!!")
		return;
	Global.coin_counter.add_money(_value);
	self.queue_free();
