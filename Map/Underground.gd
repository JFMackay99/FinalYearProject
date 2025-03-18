extends Object

class_name Underground

var heightLayers: int
var layers: Array[LayerBase]
var pathfinder: AStar3D

var layerConstructionTime: int
var pathfinderInitialisationTime: int
var totalUndergroundConstructionTime: int

func _init() -> void:
	layers = []
	layers.resize(Constants.MAX_HEIGHT_LEVELS)
	pathfinder = ModifiedAStar3D.new()
	

func setLayers(newLayers: Array[LayerBase]):
	layers = newLayers
	
func getLayers() -> Array[LayerBase]:
	return layers

func getLayer(layerHeight: int):
	return layers[layerHeight]
