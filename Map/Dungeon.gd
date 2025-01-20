extends RefCounted

class_name Dungeon

var maxHeightLayers: int
var dungeonLayers: Array[LayerBase]

func _init(maxHeights) -> void:
	maxHeightLayers = maxHeights
	dungeonLayers = []
