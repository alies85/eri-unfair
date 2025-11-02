extends CanvasLayer

@onready var username_input: LineEdit = $LineEdit

func _ready() -> void:
	username_input.placeholder_text = "...کد اعتبارسنجی گروه"
	username_input.text_changed.connect(_on_username_changed)


func _on_username_changed(new_text: String) -> void:
	# تغییر رنگ هنگام تایپ (اختیاری)
	if new_text.strip_edges() == "":
		username_input.modulate = Color(1, 0.8, 0.8)
	else:
		username_input.modulate = Color(1, 1, 1)


func is_username_filled() -> bool:
	return username_input.text.strip_edges() != ""


func get_username() -> String:
	return username_input.text.strip_edges()
