extends Spatial

export var _value : int = 25;

func _on_Area_body_entered(_body):
	if (Global.add_money == null):
		return;
	Global.add_money.call_func(_value);
	self.queue_free();
