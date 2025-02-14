extends LayerBase

class_name DungeonLayer

var tiles: Dictionary
var rooms: Array[RoomBase]

func _init(layerHeight: int, maxWidth, maxHeight, higherLevel: LayerBase = null):
	super._init(layerHeight, maxWidth, maxHeight, higherLevel)
	
	tiles = Dictionary()
	rooms = []

func SetTile(x, y, tile):
	tiles[Vector2i(x,y)] = tile

func GetTile(x, y):
	return tiles.get(Vector2i(x,y))

func ClearRooms():
	rooms.clear()

func AddRoom(room: RoomBase):
	rooms.append(room)

func ConstructRooms():
	for room in rooms:
		room.ConstructOnLayer(self)
