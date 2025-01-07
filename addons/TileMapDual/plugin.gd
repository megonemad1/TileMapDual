@tool
extends EditorPlugin


func _enter_tree() -> void:
	print("plugin TileMapDual loaded")
	add_custom_type("TileMapDual", "TileMapLayer", preload("TileMapDual.gd"), preload("TileMapDual.svg"))
	add_custom_type("CursorDual", "Sprite2D", preload("CursorDual.gd"), preload("CursorDual.svg"))


func _exit_tree() -> void:
	remove_custom_type("CursorDual")
	remove_custom_type("TileMapDual")
	print("plugin TileMapDual unloaded")
