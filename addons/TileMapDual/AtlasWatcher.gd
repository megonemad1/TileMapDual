## Watches a TileSetAtlasSource for changes.
## Causes its 'parent' TileSetWatcher to emit terrains_changed when the atlas changes.
## Also emits parent.atlas_autotiled when it thinks the user auto-generated atlas tiles.
class_name AtlasWatcher

## The TileSetWatcher that created this AtlasWatcher. Used to send signals back.
var parent: TileSetWatcher

## The Source ID of `self.atlas`.
var sid: int

## The atlas to be watched for changes.
var atlas: TileSetAtlasSource

func _init(parent: TileSetWatcher, sid: int, atlas: TileSetAtlasSource) -> void:
	self.parent = parent
	self.sid = sid
	self.atlas = atlas
	atlas.changed.connect(_atlas_changed, ConnectFlags.CONNECT_DEFERRED)
	atlas.changed.connect(_detect_autogen, ConnectFlags.CONNECT_DEFERRED | ConnectFlags.CONNECT_ONE_SHOT)


## Returns true if the texture has any opaque pixels in the specified tile coordinates.
func nonempty_tile(image: Image, tile: Vector2i) -> bool:
	# We cannot use atlas.get_tile_texture_region(tile) as it fails on unregistered tiles.
	var region := Rect2i(tile * atlas.texture_region_size, atlas.texture_region_size)
	var sprite := image.get_region(region)
	return not sprite.is_invisible()


## Called once, and only once, at the end of the first frame that a texture is created.
func _detect_autogen() -> void:
	var size := Vector2i(atlas.texture.get_size()) / atlas.texture_region_size
	var image := atlas.texture.get_image()
	var expected_tiles := []
	for y in size.y:
		for x in size.x:
			var tile := Vector2i(x, y)
			if atlas.has_tile(tile) != nonempty_tile(image, tile):
				return
	parent.atlas_autotiled.emit(sid, atlas)


## Called every time the atlas changes. Simply flags that terrains have changed.
func _atlas_changed() -> void:
	parent._flag_terrains_changed = true
