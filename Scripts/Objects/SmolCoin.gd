extends Spatial

signal coin_collected;

export var _value : int = 25;

func _on_Area_body_entered(_body):
	collect();

func collect():
	if (Global.coin_counter == null):
		print("Coin counter not found!!!")
		return;
	emit_signal("coin_collected");
	Global.coin_counter.add_money(_value);
	self.queue_free();
