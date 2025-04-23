extends RefCounted

class_name Dungeon

var pathLengthCells: int
var pathLengthPoints: int
var dungeonLayers: Array[LayerBase]

var pathfindingTime: int
var pathConstructionTime: int
var stairwellConstructionTime: int
var roomConstructionTime: int
var roomDecorationTime: int
var dungeonLayerConstructionTime: int
var totalDungeonConstructionTime: int

func _init() -> void:
	dungeonLayers = []
	dungeonLayers.resize(Constants.MAX_HEIGHT_LEVELS)
	pathLengthCells =1

func setLayers(newLayers: Array[LayerBase]):
	dungeonLayers = newLayers
	
func getLayers() -> Array[LayerBase]:
	return dungeonLayers
