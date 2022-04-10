extends Actor

class_name OverworldEnemy

export var move_speed : float = 2.0;
export var move_lerp : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export(Array, PackedScene) var enemies : Array = [];
export var reward_money : int = 25;

var target : Spatial = null;
var velocity : Vector3 = Vector3.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
		Global.current_level_controller.battle.start_battle()




