extends RefCounted

class_name Dungeon

var dungeonLayers: Array[LayerBase]

func _init() -> void:
	dungeonLayers = []
	dungeonLayers.resize(Constants.MAX_HEIGHT_LEVELS)

func setLayers(newLayers: Array[LayerBase]):
	dungeonLayers = newLayers
	
func getLayers() -> Array[LayerBase]:
	return dungeonLayers
