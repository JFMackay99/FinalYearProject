extends RefCounted

class_name Dungeon

var pathLength: int
var dungeonLayers: Array[LayerBase]

var pathfindingTime: int
var pathConstructionTime: int
var stairwellConstructionTime: int
var roomConstructionTime: int
var dungeonLayerConstructionTime: int
var totalDungeonConstructionTime: int

func _init() -> void:
	dungeonLayers = []
	dungeonLayers.resize(Constants.MAX_HEIGHT_LEVELS)
	pathLength =1

func setLayers(newLayers: Array[LayerBase]):
	dungeonLayers = newLayers
	
func getLayers() -> Array[LayerBase]:
	return dungeonLayers
