extends Object

class_name Underground

var heightLayers: int
var layers: Array[LayerBase]
var pathfinder: AStar3D


func _init() -> void:
	layers = []
	layers.resize(Constants.MAX_HEIGHT_LEVELS)
	pathfinder = ModifiedAStar3D.new()
	
