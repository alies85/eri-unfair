extends Control

const SHOP_LAYER_NAME = "ShopLayer"

var current_tab = "powers"

func _ready():
	# Set process mode to work when tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	update_gem_display()
	update_items_display()
	
	# Connect tab buttons
	$TabContainer/Powers.pressed.connect(_on_powers_tab_pressed)
	$TabContainer/Items.pressed.connect(_on_items_tab_pressed)
	$TabContainer/Customization.pressed.connect(_on_customization_tab_pressed)
	$TabContainer/MyItems.pressed.connect(_on_my_items_tab_pressed)
	
	# Connect back button (connection is idempotent in Godot 4)
	$BackButton.pressed.connect(_on_back_button_pressed)
	
	# Grab focus on first tab button
	$TabContainer/Powers.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("open_shop"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func _on_powers_tab_pressed():
	current_tab = "powers"
	update_items_display()

func _on_items_tab_pressed():
	current_tab = "items"
	update_items_display()

func _on_customization_tab_pressed():
	current_tab = "customization"
	update_items_display()

func _on_my_items_tab_pressed():
	current_tab = "my_items"
	show_my_items_tab()

func update_gem_display():
	$GemCounter.text = "الماس: " + str(Global.score)

func update_items_display():
	# Clear existing items
	for child in $ScrollContainer/ItemsContainer.get_children():
		child.queue_free()
	
	# Don't show items for my_items tab (handled separately)
	if current_tab == "my_items":
		return
	
	# Get items for current tab
	var items = ShopData.shop_items[current_tab]
	
	# Create item cards
	for item in items:
		var item_card = create_item_card(item)
		$ScrollContainer/ItemsContainer.add_child(item_card)

func create_item_card(item: Dictionary) -> Control:
	var card = VBoxContainer.new()
	card.custom_minimum_size = Vector2(150, 180)
	
	# Item name
	var name_label = Label.new()
	name_label.text = item["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	card.add_child(name_label)
	
	# Price label
	var price_label = Label.new()
	price_label.text = str(item["price"]) + " الماس"
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 16)
	card.add_child(price_label)
	
	# Buy button
	var buy_button = Button.new()
	if ShopData.is_purchased(item["id"]):
		buy_button.text = "خریداری شده"
		buy_button.disabled = true
	else:
		buy_button.text = "خرید"
		buy_button.pressed.connect(_on_buy_button_pressed.bind(item))
	buy_button.add_theme_font_size_override("font_size", 18)
	card.add_child(buy_button)
	
	return card

func _on_buy_button_pressed(item: Dictionary):
	if ShopData.purchase_item(item["id"], item["price"]):
		# Success
		update_gem_display()
		update_items_display()
		ShopData.equip_item(item["id"])
		show_message("خرید با موفقیت انجام شد!")
	else:
		# Failed
		show_message("الماس کافی ندارید!")

var message_timer: Timer = null

func show_message(text: String):
	if has_node("MessageLabel"):
		$MessageLabel.text = text
		$MessageLabel.visible = true
		
		# Cancel existing timer if any
		if message_timer and message_timer.timeout.is_connected(_hide_message):
			message_timer.timeout.disconnect(_hide_message)
			message_timer.queue_free()
		
		# Create new timer
		message_timer = Timer.new()
		message_timer.wait_time = 2.0
		message_timer.one_shot = true
		add_child(message_timer)
		message_timer.timeout.connect(_hide_message)
		message_timer.start()

func _hide_message():
	if has_node("MessageLabel"):
		$MessageLabel.visible = false
	if message_timer:
		message_timer.queue_free()
		message_timer = null

func _on_back_button_pressed():
	_on_close_pressed()

func _on_close_pressed():
	# apply purchases
	var root = get_tree().root
	for child in root.get_children():
		var player = child.find_child("Player")
		if player:
			player.apply_powerups()
			player.apply_cosmetics()
	# Check if we're in a CanvasLayer (overlay mode)
	if get_parent() and get_parent() is CanvasLayer and get_parent().name == SHOP_LAYER_NAME:
		# Free the parent CanvasLayer
		get_parent().queue_free()
		get_tree().paused = false
	elif name == "ShopOverlay":
		# Legacy fallback: direct child of scene
		queue_free()
		get_tree().paused = false
	else:
		# Fallback to scene change if not overlay
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")

func show_my_items_tab():
	# Clear existing items
	for child in $ScrollContainer/ItemsContainer.get_children():
		child.queue_free()
	
	# Get all purchased items
	var my_items = []
	for category in ShopData.shop_items.values():
		for item in category:
			if ShopData.is_purchased(item["id"]):
				my_items.append(item)
	
	# Show empty state if no items
	if my_items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "هنوز آیتمی خریداری نکرده‌اید"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 24)
		empty_label.custom_minimum_size = Vector2(400, 100)
		$ScrollContainer/ItemsContainer.add_child(empty_label)
		return
	
	# Create item cards with equip buttons
	for item in my_items:
		var item_card = create_my_item_card(item)
		$ScrollContainer/ItemsContainer.add_child(item_card)

func create_my_item_card(item: Dictionary) -> Control:
	var base_card = VBoxContainer.new()
	base_card.custom_minimum_size = Vector2(150, 200)
	
	var card = base_card
	
	# Add visual styling for equipped items
	if ShopData.is_equipped(item["id"]):
		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", create_equipped_panel_style())
		base_card.add_child(panel)
		
		var inner_card = VBoxContainer.new()
		panel.add_child(inner_card)
		card = inner_card
	
	# Item name
	var name_label = Label.new()
	name_label.text = item["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	card.add_child(name_label)
	
	# Status label
	var status_label = Label.new()
	if ShopData.is_equipped(item["id"]):
		status_label.text = "فعال"
		status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	else:
		status_label.text = "غیرفعال"
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	card.add_child(status_label)
	
	# Equip/Unequip button
	var toggle_button = Button.new()
	if ShopData.is_equipped(item["id"]):
		toggle_button.text = "غیرفعال کردن"
	else:
		toggle_button.text = "فعال کردن"
	toggle_button.pressed.connect(_on_equip_button_pressed.bind(item["id"]))
	toggle_button.add_theme_font_size_override("font_size", 18)
	card.add_child(toggle_button)
	
	return base_card

func _on_equip_button_pressed(item_id: String):
	if ShopData.is_equipped(item_id):
		ShopData.unequip_item(item_id)
		show_message("غیرفعال شد!")
	else:
		ShopData.equip_item(item_id)
		show_message("فعال شد!")
	
	# Refresh the display
	show_my_items_tab()

func create_equipped_panel_style() -> StyleBoxFlat:
	# Create a StyleBox for the equipped state
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 0.3, 0.3)  # Green tint
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.8, 0.4)  # Green border
	return style
