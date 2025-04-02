extends RefCounted

class_name RoomBase

var roomType: Constants.ROOM_TYPE
var roomShape: Constants.ROOM_SHAPE

var floor: Array[Vector2i]
var boundary: Array[Vector2i]
var doors: Array[Vector2i]
var decorations: Array

var floorTile: Constants.DUNGEON_TILES
var boundaryTile: Constants.DUNGEON_TILES
var doorTile: Constants.DUNGEON_TILES

func _init(type: Constants.ROOM_TYPE, 
	shape: Constants.ROOM_SHAPE, 
	floorTile: Constants.DUNGEON_TILES,
	boundaryTile: Constants.DUNGEON_TILES,
	doorTile = Constants.DUNGEON_TILES.DOOR):
		
	self.roomType = type
	self.roomShape = shape
	self.floorTile = floorTile
	self.boundaryTile = boundaryTile
	self.doorTile = doorTile
	self.floor = []
	self.boundary = []
	self.doors = []



func ConstructOnLayer(layer: LayerBase):
	for tile in floor:
		layer.SetTile(tile.x, tile.y, floorTile)
	for tile in boundary:
		layer.SetTile(tile.x, tile.y, boundaryTile)
	for tile in doors:
		layer.SetTile(tile.x, tile.y, doorTile)

func SeperateSection(section: Array, index: int):
	pass
	
func AddDoors(section: Array, centerIndex: int, scale: int):
	pass

func IsPointInRoom(point: Vector2i) -> bool:
	if boundary.has(point): 
		return true
	if floor.has(point):
		return true
	
	return false

func CalculateAvailableSpace():
	pass

func AddDecoration(point, decoration: Constants.ROOM_DECORATION):
	decorations.append([point, decoration])
