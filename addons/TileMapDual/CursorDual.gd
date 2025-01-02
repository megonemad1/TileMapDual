@icon('CursorDual.svg')
class_name CursorDual
extends Sprite2D

@export var tilemap_dual: TileMapDual = null

var cell: Vector2i
var tile_size: Vector2
var sprite_size: Vector2
var terrain := 1


func _ready() -> void:
	if tilemap_dual != null:
		tile_size = tilemap_dual.tile_set.tile_size
		sprite_size = self.texture.get_size()
		scale = Vector2(tile_size.y, tile_size.y) / sprite_size
		self.set_scale(scale)


func _process(_delta: float) -> void:
	if tilemap_dual == null:
		return
	global_position = tilemap_dual.map_to_local(tilemap_dual.local_to_map(get_global_mouse_position()))
	# Clicking the 1 key activates the first terrain
	if Input.is_action_pressed("quick_action_1"):
		terrain = 1
	# Clicking the 2 key activates the second terrain
	if Input.is_action_pressed("quick_action_2"):
		terrain = 2
	# Clicking the 0 key activates the background terrain
	if Input.is_action_pressed("quick_action_0"):
		terrain = 0

	cell = tilemap_dual.local_to_map(global_position)
	if Input.is_action_pressed("left_click"):
		tilemap_dual.draw_cell(cell, terrain)
	elif Input.is_action_pressed("right_click"):
		tilemap_dual.draw_cell(cell, 0)
