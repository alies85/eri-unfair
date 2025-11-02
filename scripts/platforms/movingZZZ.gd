extends Path2D

@export var move_duration: float = 1.5  # زمان حرکت به انتها (ثانیه)
@export var ease_type: Tween.TransitionType = Tween.TRANS_SINE
@export var ease_mode: Tween.EaseType = Tween.EASE_IN_OUT

signal zzz_entered

@onready var follow: PathFollow2D = $PathFollow2D

var is_moving: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_moving:
			return  # جلوگیری از اجرای چندباره
		
		is_moving = true
		
		# حرکت نرم به انتها
		var tween = create_tween()
		tween.tween_property(follow, "progress_ratio", 1.0, move_duration) \
			 .set_trans(ease_type) \
			 .set_ease(ease_mode)
		
		# وقتی تموم شد، کامل متوقف بشه
		tween.tween_callback(func():
			follow.progress_ratio = 1.0  # دقیقاً روی آخر
		)

func _on_zzz_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		zzz_entered.emit()
		
