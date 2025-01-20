extends RefCounted

class_name Dungeon

var dungeonLayers: Array[LayerBase]

func _init() -> void:
	dungeonLayers = []
	dungeonLayers.resize(Constants.MAX_HEIGHT_LEVELS)

func setLayers(layers: Array[LayerBase]):
	dungeonLayers = layers
