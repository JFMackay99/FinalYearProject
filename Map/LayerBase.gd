extends RefCounted

class_name LayerBase
var height: int

var mapMaxWidth:int
var mapMaxHeight:int

func _init(layerHeight: int, maxWidth, maxHeight) -> void:
	self.height = layerHeight
	
	mapMaxHeight = maxHeight
	mapMaxWidth = maxWidth

func SetTile( x, y, tile):
	pass
	
func GetTile( x, y):
	pass

func GetAllTiles(x, y):
	pass
