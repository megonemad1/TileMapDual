class_name AtlasWatcher

# Arguments passed to the Watcher, stored.
var parent: TileSetWatcher
var sid: int
var atlas: TileSetAtlasSource

var size: Vector2i
var expected_tiles: Array[Array]

func _init(parent: TileSetWatcher, sid: int, atlas: TileSetAtlasSource) -> void:
	self.parent = parent
	self.sid = sid
	self.atlas = atlas
	_compute_expected_tiles()
	atlas.changed.connect(_atlas_changed, ConnectFlags.CONNECT_DEFERRED)
	atlas.changed.connect(_detect_autogen, ConnectFlags.CONNECT_DEFERRED | ConnectFlags.CONNECT_ONE_SHOT)


func _compute_expected_tiles() -> void:
	size = Vector2i(atlas.texture.get_size()) / atlas.texture_region_size
	var image := atlas.texture.get_image()
	expected_tiles = []
	for y in size.y:
		var row = []
		for x in size.x:
			row.push_back(not tile_is_empty(image, Vector2i(x, y)))
		expected_tiles.push_back(row)


## Returns true if the texture has no opaque cells in the specified tile coordinates.
func tile_is_empty(image: Image, tile: Vector2i) -> bool:
	# We cannot use atlas.get_tile_texture_region(tile) as it fails on unregistered tiles.
	var region := Rect2i(tile * atlas.texture_region_size, atlas.texture_region_size)
	var sprite := image.get_region(region)
	return sprite.is_invisible()


## Called once, and only once, at the end of the first frame that a texture is created.
func _detect_autogen() -> void:
	var size := Vector2i(atlas.texture.get_size()) / atlas.texture_region_size
	if size != self.size:
		return
	for y in size.y:
		for x in size.x:
			if atlas.has_tile(Vector2i(x, y)) != expected_tiles[y][x]:
				return
	parent.atlas_autotiled.emit(sid, atlas)


func _atlas_changed() -> void:
	parent._flag_terrains_changed = true
