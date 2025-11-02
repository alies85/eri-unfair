extends Path2D

@export var speed: float = 1.0  # سرعت کلی حرکت
@export var ease_strength: float = 2.0  # شدت ease

@onready var follower: PathFollow2D = $PathFollow2D

var direction := 1.0
var progress := 0.0

func _physics_process(delta):
	progress += delta * speed * direction

	# clamp بین 0 و 1
	if progress > 1.0:
		progress = 1.0
		direction = -1
	elif progress < 0.0:
		progress = 0.0
		direction = 1

	# 🔸 ease-in-out واقعی:
	var eased = ease_in_out(progress, ease_strength)
	follower.progress_ratio = eased


# تابع سفارشی ease-in-out
func ease_in_out(t: float, strength: float) -> float:
	if t < 0.5:
		return 0.5 * ease(t * 2.0, strength)
	else:
		return 0.5 + 0.5 * (1.0 - ease((1.0 - t) * 2.0, strength))
