extends Object

class_name Underground

var heightLayers: int
var layers: Array[LayerBase]

func _init(maxHeights) -> void:
	heightLayers = heightLayers
	layers = []
	layers.resize(maxHeights)
	
	

func Refresh(maxHeights):
	heightLayers = heightLayers
	layers.clear()
	layers.resize(maxHeights)
	
