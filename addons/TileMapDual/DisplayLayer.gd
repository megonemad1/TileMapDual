## A single TileMapLayer whose purpose is to display tiles to maintain the Dual Grid illusion.
## Its contents are automatically computed and updated based on:
## - the contents of the parent TileMapDual
## - the rules set in its assigned TerrainLayer
class_name DisplayLayer
extends TileMapLayer


## How much to offset this DisplayLayer relative to the main TileMapDual grid.
## This is independent of tile size.
var offset: Vector2

## When a cell is modified in the parent TileMapDual,
## the DisplayLayer needs to know which of its display cells need to be recomputed.
## This Array stores the paths from the edited cell to the affected display cells.
var world_to_affected_display_neighbors: Array

## When a display cell needs to be recomputed,
## the TerrainLayer needs to know which tiles surround it.
## This Array stores the paths from the affected cell to the neighboring world cells.
var display_to_world_neighbors: Array

## See TileSetWatcher.gd
var _tileset_watcher: TileSetWatcher

## See TerrainDual.gd
var _terrain: TerrainDual.TerrainLayer

func _init(
	tileset_watcher: TileSetWatcher,
	fields: Dictionary,
	layer: TerrainDual.TerrainLayer
) -> void:
	#print('initializing Layer...')
	offset = fields.offset
	world_to_affected_display_neighbors = fields.world_to_affected_display_neighbors
	display_to_world_neighbors = fields.display_to_world_neighbors
	_tileset_watcher = tileset_watcher
	_terrain = layer
	tile_set = tileset_watcher.tile_set
	tileset_watcher.tileset_resized.connect(reposition, 1)
	reposition()


## Updates all display tiles to reflect the current changes.
func update_tiles_all(cache: TileCache) -> void:
	update_tiles(cache, cache.cells.keys())


func update_tiles(cache: TileCache, updated_cells: Array) -> void:
	#push_warning('updating tiles')
	var to_update := Set.new()
	for path: Array in world_to_affected_display_neighbors:
		for cell: Vector2i in updated_cells:
			cell = follow_path(cell, path)
			if to_update.insert(cell):
				update_tile(cache, cell)


func update_tile(cache: TileCache, cell: Vector2i) -> void:
	var get_cell_at_path := func(path): return get_terrain_at(cache, follow_path(cell, path))
	var normalize_terrain := func(terrain): return terrain if terrain != -1 else 0
	var true_neighborhood := display_to_world_neighbors.map(get_cell_at_path)
	var is_empty := true_neighborhood.all(func(terrain): return terrain == -1)
	var terrain_neighborhood = true_neighborhood.map(normalize_terrain)
	var invalid_neighborhood = terrain_neighborhood not in _terrain.rules
	if is_empty or invalid_neighborhood:
		erase_cell(cell)
		return
	var mapping: Dictionary = _terrain.rules[terrain_neighborhood]
	var sid: int = mapping.sid
	var tile: Vector2i = mapping.tile
	set_cell(cell, sid, tile)


func get_terrain_at(cache: TileCache, cell: Vector2i) -> int:
	if cell not in cache.cells:
		return -1
	return cache.cells[cell].terrain


func follow_path(cell: Vector2i, path: Array) -> Vector2i:
	for neighbor: TileSet.CellNeighbor in path:
		cell = get_neighbor_cell(cell, neighbor)
	return cell


func reposition() -> void:
	position = offset * Vector2(_tileset_watcher.tile_size)
