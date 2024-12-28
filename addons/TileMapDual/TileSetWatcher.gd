## Provides information about a TileSet and sends signals when it changes.
class_name TileSetWatcher
extends Resource

## Caches the previous tile_set to see when it changes.
var tile_set: TileSet
## Caches the previous tile_size to see when it changes.
var tile_size: Vector2i
## Caches the previous result of Display.tileset_grid_shape(tile_set) to see when it changes.
var grid_shape: Display.GridShape
func _init(tile_set: TileSet) -> void:
	# TODO: inline all functions here except atlas added
	tileset_deleted.connect(_tileset_deleted, 1)
	tileset_created.connect(_tileset_created, 1)
	tileset_resized.connect(_tileset_resized, 1)
	tileset_reshaped.connect(_tileset_reshaped, 1)
	atlas_added.connect(_atlas_added, 1)
	terrains_changed.connect(_terrains_changed, 1)
	update(tile_set)


var _flag_tileset_deleted := false
## Emitted when the parent TileMapDual's tile_set is cleared or replaced.
signal tileset_deleted
func _tileset_deleted():
	#print('SIGNAL EMITTED: tileset_deleted(%s)' % {})
	pass

var _flag_tileset_created := false
## Emitted when the parent TileMapDual's tile_set is created or replaced.
signal tileset_created
func _tileset_created():
	#print('SIGNAL EMITTED: tileset_created(%s)' % {})
	pass

var _flag_tileset_resized := false
## Emitted when tile_set.tile_size is changed.
signal tileset_resized
func _tileset_resized():
	#print('SIGNAL EMITTED: tileset_resized(%s)' % {})
	pass

var _flag_tileset_reshaped := false
## Emitted when the GridShape of the TileSet would be different.
signal tileset_reshaped
func _tileset_reshaped():
	#print('SIGNAL EMITTED: tileset_reshaped(%s)' % {})
	pass

var _flag_atlas_added := false
## Emitted when a new Atlas is added to this TileSet.
## Does not react to Scenes being added to the TileSet.
signal atlas_added(source_id: int, atlas: TileSetAtlasSource)
func _atlas_added(source_id: int, atlas: TileSetAtlasSource):
	_flag_atlas_added = true
	#print('SIGNAL EMITTED: atlas_added(%s)' % {'source_id': source_id, 'atlas': atlas})
	pass

var _flag_terrains_changed := false
## Emitted when an atlas is added or removed,
## or when the terrains change in one of the Atlases.
## NOTE: Prefer connecting to TerrainDual.changed instead of TileSetWatcher.terrains_changed.
signal terrains_changed
func _terrains_changed():
	#print('SIGNAL EMITTED: terrains_changed(%s)' % {})
	pass


## Checks if anything about the concerned TileMapDual's tile_set changed.
## Must be called by the TileMapDual every frame.
func update(tile_set: TileSet) -> void:
	check_tile_set(tile_set)
	check_flags()


## Emit update signals if the corresponding flags were set.
## Must only be run once per frame.
func check_flags() -> void:
	if _flag_tileset_changed:
		_check_tileset()
	if _flag_tileset_deleted:
		_flag_tileset_deleted = false
		_flag_tileset_reshaped = true
		tileset_deleted.emit()
	if _flag_tileset_created:
		_flag_tileset_created = false
		_flag_tileset_reshaped = true
		tileset_created.emit()
	if _flag_tileset_resized:
		_flag_tileset_resized = false
		tileset_resized.emit()
	if _flag_tileset_reshaped:
		_flag_tileset_reshaped = false
		_flag_terrains_changed = true
		tileset_reshaped.emit()
	if _flag_atlas_added:
		_flag_atlas_added = false
		_flag_terrains_changed = true
	if _flag_terrains_changed:
		_flag_terrains_changed = false
		terrains_changed.emit()


## Check if tile_set has been added, replaced, or deleted.
func check_tile_set(tile_set: TileSet) -> void:
	if tile_set == self.tile_set:
		return
	if self.tile_set != null:
		self.tile_set.changed.disconnect(_set_tileset_changed)
		_cached_source_count = 0
		_cached_sids.clear()
		_flag_tileset_deleted = true
	self.tile_set = tile_set
	if self.tile_set != null:
		self.tile_set.changed.connect(_set_tileset_changed, 1)
		self.tile_set.emit_changed()
		_flag_tileset_created = true
	emit_changed()


var _flag_tileset_changed := false
## Helper method to be called when the tile_set detects a change.
## Must be disconnected when the tile_set is changed.
func _set_tileset_changed() -> void:
	_flag_tileset_changed = true


## Called when _flag_tileset_changed.
## Provides more detail about what changed.
func _check_tileset() -> void:
	var tile_size = tile_set.tile_size
	if self.tile_size != tile_size:
		self.tile_size = tile_size
		_flag_tileset_resized = true
	var grid_shape = Display.tileset_gridshape(tile_set)
	if self.grid_shape != grid_shape:
		self.grid_shape = grid_shape
		_flag_tileset_reshaped = true
	_check_tileset_atlases()


# Cached variables from the previous frame
# These are used to compare what changed between frames
var _cached_source_count: int = 0
var _cached_sids := Set.new()
# TODO: detect automatic tile creation
## Checks if new atlases have been added.
## Does not check which ones were deleted.
func _check_tileset_atlases():
	# Update all tileset sources
	var source_count := tile_set.get_source_count()
	var terrain_set_count := tile_set.get_terrain_sets_count()

	# Only if an asset was added or removed
	# FIXME?: may break on add+remove in 1 frame
	if _cached_source_count == source_count:
		return
	_cached_source_count = source_count

	# Process the new atlases in the TileSet
	var sids := Set.new()
	for i in source_count:
		var sid: int = tile_set.get_source_id(i)
		sids.insert(sid)
		if _cached_sids.has(sid):
			continue
		var source: TileSetSource = tile_set.get_source(sid)
		if source is not TileSetAtlasSource:
			push_warning(
				"Non-Atlas TileSet found at index %i, source id %i.\n" % [i, source] +
				"Dual Grids only support Atlas TileSets."
			)
			continue
		var atlas: TileSetAtlasSource = source
		atlas_added.emit(sid, atlas)
		# FIXME?: check if this needs to be disconnected
		# SETUP:
		# - add logging to check which Watcher's flag was changed
		# - add a TileSet with an atlas to 2 TileMapDuals
		# - remove the TileSet
		# - modify the terrains on one of the atlases
		# - check how many watchers were flagged:
		#   - if 2 watchers were flagged, this is bad.
		#     try to repeatedly add and remove the tileset.
		#     this could either cause the flag to happen multiple times,
		#     or it could stay at 2 watchers.
		#   - if 1 watcher was flagged, that is ok
		atlas.changed.connect(func(): _flag_terrains_changed = true, 1)
	_flag_terrains_changed = true
	# FIXME?: find which sid's were deleted
	_cached_sids = sids
