extends Actor

class_name OverworldEnemy

signal battle_end
signal battle_start

export var move_speed : float = 2.0;
export var move_lerp : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export(Array, PackedScene) var enemies : Array = [];
export var reward_money : int = 25;

var enemies_instanced : Array = []

var target : Spatial = null;
var velocity : Vector3 = Vector3.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in enemies:
		enemies_instanced.push_back(enemy.instance());
	
# warning-ignore:return_value_discarded
	Global.connect("scene_is_changing", self, "_kill");
# warning-ignore:return_value_discarded
	Global.connect("scene_is_reloading", self, "_kill");

func _physics_process(delta):
	velocity += gravity * delta;
	
	if (target != null):
		var vector_to_target : Vector3 = target.global_transform.origin - global_transform.origin;
		vector_to_target.y = 0.0;
		
		vector_to_target = vector_to_target.normalized();
		vector_to_target *= move_speed;
		
		velocity.x = lerp(velocity.x, vector_to_target.x, delta * move_lerp);
		velocity.z = lerp(velocity.z, vector_to_target.z, delta * move_lerp);
	
	velocity = move_and_slide(velocity, Vector3.UP);

func _on_AggroArea_body_entered(body):
	if (body is Player):
		target = body;

func _on_PlayerDetectorArea_body_entered(body):
	if (body is Player):
		Global.current_level_controller.battle.start_battle(body.party, enemies_instanced);
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_start", self, "_battle_start");
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_end", self, "_battle_end");

func _battle_start():
	emit_signal("battle_start");

func _battle_end():
	emit_signal("battle_end");
	Global.coin_counter.add_money(reward_money);
	_kill();

func _kill():
	for enemy in enemies_instanced:
		enemy.queue_free();
	queue_free();
