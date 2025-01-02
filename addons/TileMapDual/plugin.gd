@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("TileMapDual", "TileMapLayer", preload("TileMapDual.gd"), preload("TileMapDual.svg"))
	add_custom_type("CursorDual", "Sprite2D", preload("CursorDual.gd"), preload("CursorDual.svg"))


# TODO
#func _handles(object: Object):
#	return object is TileMapDual

func _exit_tree():
	remove_custom_type("TileMapDual")
	remove_custom_type("CursorDual")
