extends SquareRoom

class_name SquareStairwell

var center
var stairType: Constants.DUNGEON_TILES

func _init(
	width: int,
	center: Vector2i,
	stairTile: Constants.DUNGEON_TILES
	):
	super(Constants.ROOM_TYPE.STAIRWELL, width, center)
	self.center = center
	stairType = stairTile
	
func ConstructOnLayer(layer: LayerBase):
	super(layer)
	layer.SetTile(center.x, center.y, stairType)
