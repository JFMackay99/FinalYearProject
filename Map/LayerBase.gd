extends RefCounted

class_name LayerBase
var height: int

var HigherLevel: LayerBase = null
var LowerLevel: LayerBase = null

var mapMaxWidth:int
var mapMaxHeight:int

func _init(layerHeight: int, maxWidth, maxHeight, higherLevel: LayerBase = null) -> void:
	self.height = layerHeight
	if higherLevel != null:
		self.HigherLevel = higherLevel
		higherLevel.LowerLevel = self
	
	mapMaxHeight = maxHeight
	mapMaxWidth = maxWidth

func SetTile( x, y, tile):
	pass
	
func GetTile( x, y):
	pass


func SetLowerLevel(newLevel: LayerBase):
	LowerLevel = newLevel

func SetHigherLevel(newLevel: LayerBase):
	HigherLevel = newLevel
