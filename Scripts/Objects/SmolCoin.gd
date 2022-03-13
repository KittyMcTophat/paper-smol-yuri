extends Spatial

export var _value : int = 25;

func _on_Area_body_entered(_body):
	collect();

func collect():
	if (Global.coin_counter == null):
		print("Coin counter not found!!!")
		return;
	Global.coin_counter.add_money(_value);
	self.queue_free();
