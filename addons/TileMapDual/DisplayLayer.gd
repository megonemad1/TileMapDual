## A single TileMapLayer whose purpose is to display tiles to maintain the Dual Grid illusion.
## Its contents are automatically computed and updated based on:
## - the contents of the parent TileMapDual
## - the rules set in its assigned TerrainLayer
class_name DisplayLayer
extends TileMapLayer


## How much to offset this DisplayLayer relative to the main TileMapDual grid.
## This is independent of tile size.
var offset: Vector2

## See TileSetWatcher.gd
var _tileset_watcher: TileSetWatcher

## See TerrainDual.gd
var _terrain: TerrainLayer

## the sub tile used to suport composite tiles
var sub_display = null

func _init(
	world: TileMapDual,
	tileset_watcher: TileSetWatcher,
	fields: Dictionary,
	layer: TerrainLayer
) -> void:
	# TODO: clone all properties of world: TileMapDual
	# possibly serialize the parent and use a for loop?
	#print('initializing Layer...')
	offset = fields.offset
	_tileset_watcher = tileset_watcher
	_terrain = layer
	tile_set = tileset_watcher.tile_set
	tileset_watcher.tileset_resized.connect(reposition, 1)
	reposition()


## Adjusts the position of this DisplayLayer based on the tile set's tile_size
func reposition() -> void:
	position = offset * Vector2(_tileset_watcher.tile_size)


## Updates all display tiles to reflect the current changes.
func update_tiles_all(cache: TileCache) -> void:
	update_tiles(cache, cache.cells.keys())


## Update all display tiles affected by the world cells
func update_tiles(cache: TileCache, updated_world_cells: Array) -> void:
	#push_warning('updating tiles')
	var already_updated := Set.new()
	for path: Array in _terrain.display_to_world_neighborhood:
		path = path.map(Util.reverse_neighbor)
		for world_cell: Vector2i in updated_world_cells:
			var display_cell := follow_path(world_cell, path)
			if already_updated.insert(display_cell):
				update_tile(cache, display_cell)


## Updates a specific world cell.
func update_tile(cache: TileCache, cell: Vector2i) -> void:
	var get_cell_at_path := func(path): return cache.get_terrain_at(follow_path(cell, path))
	var terrain_neighbors := _terrain.display_to_world_neighborhood.map(get_cell_at_path)
	var unique_lst={}
	if _tileset_watcher.is_composite():
		for t in terrain_neighbors:
			if t not in unique_lst.keys():
				unique_lst[t]=terrain_neighbors.map(func(x): return t if t==x else min(0,x))
		var sorted_keys = unique_lst.keys()
		sorted_keys.sort()
		var sorted_values = sorted_keys.map(func(x): return unique_lst[x])
		cascade(sorted_values,cell)
	else:
		if sub_display != null:
			sub_display.queue_free()
		var mapping: Dictionary = _terrain.apply_rule(terrain_neighbors)
		var sid: int = mapping.sid
		var tile: Vector2i = mapping.tile
		set_cell(cell, sid, tile)


func cascade(terrain_neighbors_lst: Array, cell: Vector2i):
	var mapping: Dictionary = _terrain.TILE_EMPTY
	if terrain_neighbors_lst.size()>0:
		var terrain_neighbors=terrain_neighbors_lst[0]
		mapping = _terrain.apply_rule(terrain_neighbors)
		terrain_neighbors_lst= terrain_neighbors_lst.slice(1)
	var sid: int = mapping.sid
	var tile: Vector2i = mapping.tile
	set_cell(cell, sid, tile)
	if sub_display != null or terrain_neighbors_lst.size()>0:
		var sub_layer=get_or_make_sub_render_layer()
		sub_layer.cascade(terrain_neighbors_lst,cell)

func get_or_make_sub_render_layer() -> DisplayLayer:
	if sub_display != null:
		return sub_display
	sub_display = DisplayLayer.new(null,_tileset_watcher, {"offset":Vector2.ZERO}, _terrain)
	add_child(sub_display)
	return sub_display

## Finds the neighbor of a given cell by following a path of CellNeighbors
func follow_path(cell: Vector2i, path: Array) -> Vector2i:
	for neighbor: TileSet.CellNeighbor in path:
		cell = get_neighbor_cell(cell, neighbor)
	return cell
