extends Control

var current_tab = "powers"

func _ready():
	update_gem_display()
	update_items_display()
	
	# Connect tab buttons
	$TabContainer/Powers.pressed.connect(_on_powers_tab_pressed)
	$TabContainer/Items.pressed.connect(_on_items_tab_pressed)
	$TabContainer/Customization.pressed.connect(_on_customization_tab_pressed)
	
	# Connect back button
	$BackButton.pressed.connect(_on_back_button_pressed)

func _on_powers_tab_pressed():
	current_tab = "powers"
	update_items_display()

func _on_items_tab_pressed():
	current_tab = "items"
	update_items_display()

func _on_customization_tab_pressed():
	current_tab = "customization"
	update_items_display()

func update_gem_display():
	$GemCounter.text = "الماس: " + str(ShopData.total_gems)

func update_items_display():
	# Clear existing items
	for child in $ItemsContainer.get_children():
		child.queue_free()
	
	# Get items for current tab
	var items = ShopData.shop_items[current_tab]
	
	# Create item cards
	for item in items:
		var item_card = create_item_card(item)
		$ItemsContainer.add_child(item_card)

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
		show_message("خرید با موفقیت انجام شد!")
	else:
		# Failed
		show_message("الماس کافی ندارید!")

func show_message(text: String):
	if has_node("MessageLabel"):
		$MessageLabel.text = text
		$MessageLabel.visible = true
		await get_tree().create_timer(2.0).timeout
		$MessageLabel.visible = false

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
