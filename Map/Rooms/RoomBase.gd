extends RefCounted

class_name RoomBase

var roomType: Constants.ROOM_TYPE
var roomShape: Constants.ROOM_SHAPE

var floor: Array[Vector2i]
var boundary: Array[Vector2i]

var floorTile: Constants.DUNGEON_TILES
var boundaryTile: Constants.DUNGEON_TILES
