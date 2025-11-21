extends Node

# Shop items data structure
var shop_items = {
	"powers": [
		{"id": "double_jump", "name": "پرش دوبل", "price": 5, "icon": "res://assets/icon.svg"},
		{"id": "speed_boost", "name": "افزایش سرعت", "price": 3, "icon": "res://assets/icon.svg"},
		{"id": "shield", "name": "سپر", "price": 4, "icon": "res://assets/icon.svg"},
		{"id": "jump_boost", "name": "افزایش پرش", "price": 3, "icon": "res://assets/icon.svg"}
	],
	"items": [
		{"id": "extra_life", "name": "جان اضافی", "price": 10, "icon": "res://assets/icon.svg"},
		{"id": "gem_magnet", "name": "آهنربای الماس", "price": 5, "icon": "res://assets/icon.svg"},
		{"id": "slow_motion", "name": "حرکت آهسته", "price": 6, "icon": "res://assets/icon.svg"}
	],
	"customization": [
		{"id": "red_skin", "name": "پوست قرمز", "price": 8, "icon": "res://assets/icon.svg"},
		{"id": "blue_skin", "name": "پوست آبی", "price": 8, "icon": "res://assets/icon.svg"},
		{"id": "rainbow_trail", "name": "دنباله رنگین‌کمان", "price": 12, "icon": "res://assets/icon.svg"},
		{"id": "star_particles", "name": "ذرات ستاره", "price": 10, "icon": "res://assets/icon.svg"}
	]
}

# Player data
var total_gems = 0
var purchased_items = []
var equipped_items = {
	"skin": "default",
	"trail": "none",
	"particles": "none"
}

const SAVE_PATH = "user://shopdata.save"

# For testing: Set to true to start with test gems
const DEBUG_MODE = false
const DEBUG_GEMS = 50

func _ready():
	load_data()
	# For testing: Give starting gems if debug mode is enabled
	if DEBUG_MODE and total_gems == 0:
		total_gems = DEBUG_GEMS
		save_data()

# Check if item is purchased
func is_purchased(item_id: String) -> bool:
	return item_id in purchased_items

# Purchase an item
func purchase_item(item_id: String, price: int) -> bool:
	if total_gems >= price and not is_purchased(item_id):
		total_gems -= price
		purchased_items.append(item_id)
		save_data()
		return true
	return false

# Add gems
func add_gems(amount: int):
	total_gems += amount
	save_data()

# Get item by id
func get_item_by_id(item_id: String) -> Dictionary:
	for category in shop_items.values():
		for item in category:
			if item["id"] == item_id:
				return item
	return {}

# Equip a cosmetic item
func equip_item(item_id: String, slot: String):
	if is_purchased(item_id):
		equipped_items[slot] = item_id
		save_data()

# Save data to file
func save_data():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var data = {
			"total_gems": total_gems,
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
				total_gems = data.get("total_gems", 0)
				purchased_items = data.get("purchased_items", [])
				equipped_items = data.get("equipped_items", {
					"skin": "default",
					"trail": "none",
					"particles": "none"
				})

# Reset shop data (useful for testing)
func reset_data():
	total_gems = 0
	purchased_items = []
	equipped_items = {
		"skin": "default",
		"trail": "none",
		"particles": "none"
	}
	save_data()
