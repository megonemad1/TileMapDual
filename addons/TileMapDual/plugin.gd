@tool
extends EditorPlugin


# TODO: create a message queue that groups warnings, errors, and messages into categories
# so that we don't get 300 lines of the same warnings pushed to console every time we undo/redo


func _enter_tree() -> void:
	print("plugin TileMapDual loaded")
	add_custom_type("TileMapDual", "TileMapLayer", preload("TileMapDual.gd"), preload("TileMapDual.svg"))
	add_custom_type("CursorDual", "Sprite2D", preload("CursorDual.gd"), preload("CursorDual.svg"))


func _exit_tree() -> void:
	remove_custom_type("CursorDual")
	remove_custom_type("TileMapDual")
	print("plugin TileMapDual unloaded")
