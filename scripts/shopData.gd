extends Node

# Shop items data structure
var shop_items = {
	"powers": [
		{"id": "double_jump", "name": "پرش دوبل", "price": 5, "icon": "res://assets/icon.svg"},
		{"id": "speed_boost", "name": "افزایش سرعت", "price": 3, "icon": "res://assets/icon.svg"},
		{"id": "shield", "name": "سپر", "price": 4, "icon": "res://assets/icon.svg"},
		{"id": "jump_boost", "name": "افزایش پرش", "price": 3, "icon": "res://assets/icon.svg"},
		{"id": "10x_jump_boost", "name": "افزایش پرش *10", "price": 3, "icon": "res://assets/icon.svg"}
	],
	"items": [
		{"id": "extra_life", "name": "جان اضافی", "price": 10, "icon": "res://assets/icon.svg"},
		{"id": "gem_magnet", "name": "آهنربای الماس", "price": 5, "icon": "res://assets/icon.svg"},
		{"id": "slow_motion", "name": "حرکت آهسته", "price": 6, "icon": "res://assets/icon.svg"}
	],
	"customization": [
		{"id": "red_skin", "name": "پوست قرمز", "price": 8, "icon": "res://assets/icon.svg"},
		{"id": "blue_skin", "name": "پوست آبی", "price": 8, "icon": "res://assets/icon.svg"},
		{"id": "green_skin", "name": "پوست سبز", "price": 8, "icon": "res://assets/icon.svg"},
		{"id": "diamond_trail", "name": "دنباله الماس", "price": 12, "icon": "res://assets/icon.svg"},
		{"id": "rainbow_trail", "name": "دنباله رنگین‌کمان", "price": 12, "icon": "res://assets/icon.svg"},
		{"id": "star_particles", "name": "ذرات ستاره", "price": 10, "icon": "res://assets/icon.svg"}
	]
}

# Player data
var purchased_items = []
var equipped_items = {}  # Dictionary of item_id -> true for equipped items

const SAVE_PATH = "user://shopdata.save"

func _ready():
	load_data()
	
	reset_data()

# Check if item is purchased
func is_purchased(item_id: String) -> bool:
	return item_id in purchased_items

# Check if item is equipped
func is_equipped(item_id: String) -> bool:
	return equipped_items.get(item_id, false)

# Purchase an item
func purchase_item(item_id: String, price: int) -> bool:
	if Global.score >= price and not is_purchased(item_id):
		Global.score -= price
		purchased_items.append(item_id)
		save_data()
		return true
	return false

# Get item by id
func get_item_by_id(item_id: String) -> Dictionary:
	for category in shop_items.values():
		for item in category:
			if item["id"] == item_id:
				return item
	return {}

# Get category of an item
func get_item_category(item_id: String) -> String:
	for category_name in shop_items.keys():
		for item in shop_items[category_name]:
			if item["id"] == item_id:
				return category_name
	return ""

# Equip an item
func equip_item(item_id: String) -> bool:
	if not is_purchased(item_id):
		return false
	
	# Handle category exclusivity for skins
	var category = get_item_category(item_id)
	if category == "customization":
		# Check if it's a skin (red_skin, blue_skin, green_skin)
		if item_id in ["red_skin", "blue_skin", "green_skin"]:
			# Unequip all other skins
			for skin_id in ["red_skin", "blue_skin", "green_skin"]:
				if skin_id != item_id and is_equipped(skin_id):
					equipped_items.erase(skin_id)
		
		if item_id in ["star_particles", "rainbow_trail", "diamond_trail"]:
			for skin_id in ["star_particles", "rainbow_trail", "diamond_trail"]:
				if skin_id != item_id and is_equipped(skin_id):
					equipped_items.erase(skin_id)
	
	equipped_items[item_id] = true
	save_data()
	return true

# Unequip an item
func unequip_item(item_id: String) -> bool:
	if is_equipped(item_id):
		equipped_items.erase(item_id)
		save_data()
		return true
	return false

# Get list of equipped items
func get_equipped_items() -> Array:
	return equipped_items.keys()

# Save data to file
func save_data():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var data = {
			"purchased_items": purchased_items,
			"equipped_items": equipped_items
		}
		save_file.store_string(JSON.stringify(data))
		save_file.close()

# Load data from file
func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.data
				purchased_items = data.get("purchased_items", [])
				
				# Handle both old and new equipped_items format
				var loaded_equipped = data.get("equipped_items", {})
				if loaded_equipped is Dictionary:
					# Check if it's the old slot-based format
					if "skin" in loaded_equipped or "trail" in loaded_equipped or "particles" in loaded_equipped:
						# Convert old format to new format
						equipped_items = {}
						var old_skin = loaded_equipped.get("skin", "default")
						if old_skin != "default" and old_skin != "none":
							equipped_items[old_skin] = true
						var old_trail = loaded_equipped.get("trail", "none")
						if old_trail != "none":
							equipped_items[old_trail] = true
						var old_particles = loaded_equipped.get("particles", "none")
						if old_particles != "none":
							equipped_items[old_particles] = true
					else:
						# New format
						equipped_items = loaded_equipped

# Reset shop data (useful for testing)
func reset_data():
	purchased_items = []
	equipped_items = {}
	save_data()
