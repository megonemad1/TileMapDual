## A set of _rules usable by a single DisplayLayer.
class_name TerrainLayer
extends Resource


## A list of which CellNeighbors to care about during terrain checking.
var terrain_neighbors: Array = []

## When a cell in a DisplayLayer needs to be recomputed,
## the TerrainLayer needs to know which tiles surround it.
## This Array stores the paths from the affected cell to the neighboring world cells.
var display_to_world_neighbors: Array

# TODO: support 'any' connections
## rules: Dictionary{
##   key: Condition = The terrains that surround this tile.
##   value: {
##     'sid': int = The Source ID of this tile.
##     'tile': Vector2i = The coordinates of this tile in its Atlas.
##   } = The sprite that will be chosen when the condition is satisfied.
## }
##
## Condition: Array[
##   type: int = The terrain found at this position in the filter.
##   size = filter.size()
## ]
var _rules: Dictionary = {}


func apply_rule(condition: Array) -> Dictionary:
	if condition not in _rules:
		return {'sid': - 1, 'tile': Vector2i(-1, -1)}
	return _rules[condition]


func _init(fields: Dictionary) -> void:
	self.terrain_neighbors = fields.terrain_neighbors
	self.display_to_world_neighbors = fields.display_to_world_neighbors


## Register a new rule for a specific tile in an atlas.
func _register_tile(data: TileData, mapping: Dictionary) -> void:
	if data.terrain_set != 0:
		# This was already handled as an error in the parent TerrainDual
		return
	var condition := terrain_neighbors.map(data.get_terrain_peering_bit)
	# Skip tiles with no peering bits in this filter
	# They might be used for a different layer,
	# or may have no peering bits at all, which will just be ignored by all layers
	if condition.any(func(neighbor): return neighbor == -1):
		if condition.any(func(neighbor): return neighbor != -1):
			push_warning(
				"Invalid Tile Neighbors at %s.\n" % [mapping] +
				"Expected neighbors: %s" % [terrain_neighbors.map(Util.neighbor_name)]
			)
		return
	if condition in _rules:
		var prev_mapping = _rules[condition]
		push_warning(
			"2 different tiles in this TileSet have the same Terrain neighborhood:\n" +
			"Condition: %s\n" % [_condition_to_dict(condition)] +
			"1st: %s\n" % [prev_mapping] +
			"2nd: %s" % [mapping]
		)
	_rules[condition] = mapping

## Utility function for easier printing
func _condition_to_dict(condition: Array) -> Dictionary:
	return Util.arrays_to_dict(terrain_neighbors.map(Util.neighbor_name), condition)
