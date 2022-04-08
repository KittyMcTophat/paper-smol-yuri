extends Camera

onready var width : float = ProjectSettings.get_setting("display/window/size/width");
onready var height : float = ProjectSettings.get_setting("display/window/size/height");
onready var width_over_height : float = width / height;

var vertical_fov : float = 70.0;
var horizontal_fov : float = 102.447858;

func _ready():
	if (keep_aspect == Camera.KEEP_HEIGHT):
		vertical_fov = fov;
		horizontal_fov = rad2deg(atan((tan(deg2rad(vertical_fov / 2)) * width) / height)) * 2;
	else:
		horizontal_fov = fov;
		vertical_fov = rad2deg(atan((tan(deg2rad(horizontal_fov / 2)) * height) / width)) * 2;
	
# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_update_fov");
	
	_update_fov();

func _update_fov():
	var viewport_size : Vector2 = get_viewport().size;
	
	if (float(viewport_size.x) / float(viewport_size.y) >= width_over_height):
		_keep_height();
	else:
		_keep_width();

func _keep_height():
	keep_aspect = Camera.KEEP_HEIGHT;
	fov = vertical_fov;

func _keep_width():
	keep_aspect = Camera.KEEP_WIDTH;
	fov = horizontal_fov;
