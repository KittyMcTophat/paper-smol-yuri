extends Area

class_name Projectile

export var speed : float = 3.0;
export var damage : int = 1;
export var direction : Vector3 = Vector3.LEFT;
export var pierces_targets : bool = false;
export var spin : bool = false;
export var spin_velocity : float = 30.0;

onready var _sprite3d : Sprite3D = $Sprite3D;
onready var _visibility_notifier : VisibilityNotifier = $VisibilityNotifier;

var _is_first_frame_alive : bool = true;

func _ready():
	set_direction(direction);

func _physics_process(delta):
	transform.origin += direction * speed * delta;
	
	if (spin):
		var spin_mult : float = 1.0;
		if (direction.x < 0.0):
			spin_mult = -1.0;
		_sprite3d.transform = _sprite3d.transform.rotated(Vector3.FORWARD, deg2rad(spin_velocity) * delta * spin_mult);
	
	#visibility notifier needs one frame before being called
	if (_is_first_frame_alive):
		_is_first_frame_alive = false;
		return;
	
	if (!_visibility_notifier.is_on_screen()):
		queue_free();

func set_direction(new_direction : Vector3):
	direction = new_direction.normalized();
	var vec2direction : Vector2 = Vector2(direction.x, direction.y).normalized();
	
	_sprite3d.rotation = Vector3(0.0, vec2direction.angle(), 0.0);

func _on_BaseProjectile_body_entered(body):
	if (damage >= 0):
		if (body.has_method("hurt")):
			body.hurt(damage);
			if (!pierces_targets):
				queue_free();
	else:
		if (body.has_method("heal")):
			body.heal(-damage);
			if (!pierces_targets):
				queue_free();

func set_damage(amount : int):
	damage = amount;
