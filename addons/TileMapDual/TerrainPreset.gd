## Functions for automatically generating terrains for an atlas.
class_name TerrainPreset


## Every corner CellNeighbor, in order.
const NEIGHBORS: Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
]

## Maps a Neighborhood to a Topology.
const NEIGHBORHOOD_TOPOLOGIES := {
	TerrainDual.Neighborhood.SQUARE: Topology.SQUARE,
	TerrainDual.Neighborhood.ISOMETRIC: Topology.SQUARE,
	TerrainDual.Neighborhood.TRIANGLE_HORIZONTAL: Topology.TRIANGLE,
	TerrainDual.Neighborhood.TRIANGLE_VERTICAL: Topology.TRIANGLE,
}


## Determines the available Terrain presets for a certain Atlas.
enum Topology {
	SQUARE,
	TRIANGLE,
}


## Maps a Neighborhood to a preset of the specified name.
static func neighborhood_preset(
	neighborhood: TerrainDual.Neighborhood,
	preset_name: String = 'Standard'
) -> Dictionary:
	var topology: Topology = NEIGHBORHOOD_TOPOLOGIES[neighborhood]
	# TODO: test when the preset doesn't exist
	var available_presets = PRESETS[topology]
	if preset_name not in available_presets:
		return {'size': Vector2i.ONE, 'layers': []}
	var out: Dictionary = available_presets[preset_name].duplicate(true)
	# All Horizontal neighborhoods can be transposed to Vertical
	if neighborhood == TerrainDual.Neighborhood.TRIANGLE_VERTICAL:
		out.size = Util.transpose_vec(out.size)
		for seq in out.layers:
			for i in seq.size():
				seq[i] = Util.transpose_vec(seq[i])
	return out


## Contains all of the builtin Terrain presets for each topology
const PRESETS := {
	Topology.SQUARE: {
		'Standard': {
			'size': Vector2i(4, 4),
			'bg': Vector2i(0, 3),
			'fg': Vector2i(2, 1),
			'layers': [
				[ # []
					Vector2i(0, 3),
					Vector2i(3, 3),
					Vector2i(0, 2),
					Vector2i(1, 2),
					Vector2i(0, 0),
					Vector2i(3, 2),
					Vector2i(2, 3),
					Vector2i(3, 1),
					Vector2i(1, 3),
					Vector2i(0, 1),
					Vector2i(1, 0),
					Vector2i(2, 2),
					Vector2i(3, 0),
					Vector2i(2, 0),
					Vector2i(1, 1),
					Vector2i(2, 1),
				],
			],
		},
	},
	Topology.TRIANGLE: {
		'Standard': {
			'size': Vector2i(4, 4),
			'bg': Vector2i(0, 0),
			'fg': Vector2i(2, 0),
			'layers': [
				[ # v
					Vector2i(0, 1),
					Vector2i(2, 1),
					Vector2i(3, 1),
					Vector2i(1, 3),
					Vector2i(1, 1),
					Vector2i(3, 3),
					Vector2i(2, 3),
					Vector2i(0, 3),
				],
				[ # ^
					Vector2i(0, 0),
					Vector2i(2, 0),
					Vector2i(3, 0),
					Vector2i(1, 2),
					Vector2i(1, 0),
					Vector2i(3, 2),
					Vector2i(2, 2),
					Vector2i(0, 2),
				],
			]
		},
		'Alternating': {
			'size': Vector2i(4, 4),
			'bg': Vector2i(0, 0),
			'fg': Vector2i(2, 0),
			'layers': [
				[ # v
					Vector2i(0, 0),
					Vector2i(2, 0),
					Vector2i(3, 1),
					Vector2i(1, 3),
					Vector2i(1, 1),
					Vector2i(3, 3),
					Vector2i(2, 2),
					Vector2i(0, 2),
				],
				[ # ^
					Vector2i(0, 1),
					Vector2i(2, 1),
					Vector2i(3, 0),
					Vector2i(1, 2),
					Vector2i(1, 0),
					Vector2i(3, 2),
					Vector2i(2, 3),
					Vector2i(0, 3),
				],
			],
		},
	},
}


## Would you like to automatically create tiles in the atlas?
static func write_default_preset(tile_set: TileSet, atlas: TileSetAtlasSource) -> void:
	#print('writing default')
	var neighborhood := TerrainDual.tileset_neighborhood(tile_set)
	var terrain_offset := _create_false_terrain_set(
		tile_set,
		atlas.texture.resource_path.get_file()
	)
	write_preset(
		atlas,
		neighborhood,
		neighborhood_preset(neighborhood),
		terrain_offset + 0,
		terrain_offset + 1,
	)


## Adds 2 new terrain types to terrain set 0 for the sprites to use.
static func _create_false_terrain_set(tile_set: TileSet, terrain_name: String) -> int:
	if tile_set.get_terrain_sets_count() == 0:
		tile_set.add_terrain_set()
		tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	var terrain_offset = tile_set.get_terrains_count(0)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, terrain_offset + 0, "BG -%s" % terrain_name)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, terrain_offset + 1, "FG -%s" % terrain_name)
	return terrain_offset


## Takes a preset and puts it onto the given atlas.
## ARGUMENTS:
## - atlas: the atlas source to apply the preset to.
## - filters: the neighborhood filter
static func write_preset(
	atlas: TileSetAtlasSource,
	neighborhood: TerrainDual.Neighborhood,
	preset: Dictionary,
	terrain_background: int,
	terrain_foreground: int,
) -> void:
	var layers: Array = TerrainDual.NEIGHBORHOOD_LAYERS[neighborhood]
	#print('writing')
	clear_and_resize_atlas(atlas, preset.size)
	# Set peering bits
	var sequences: Array = preset.layers
	for j in layers.size():
		var filter = layers[j].terrain_neighbors
		var sequence: Array = sequences[j]
		for i in sequence.size():
			var tile: Vector2i = sequence[i]
			atlas.create_tile(tile)
			var data := atlas.get_tile_data(tile, 0)
			data.terrain_set = 0
			for neighbor in filter:
				data.set_terrain_peering_bit(
					neighbor,
					[terrain_background, terrain_foreground][i & 1]
				)
				i >>= 1
	# Set terrains
	atlas.get_tile_data(preset.bg, 0).terrain = terrain_background
	atlas.get_tile_data(preset.fg, 0).terrain = terrain_foreground


## Unregisters all the tiles in an atlas and changes the size of the
## individual sprites to accomodate a size.x by size.y grid of sprites.
static func clear_and_resize_atlas(atlas: TileSetAtlasSource, size: Vector2i):
	# Clear all tiles
	atlas.texture_region_size = atlas.texture.get_size() + Vector2.ONE
	atlas.clear_tiles_outside_texture()
	# Resize the tiles
	atlas.texture_region_size = atlas.texture.get_size() / Vector2(size)
