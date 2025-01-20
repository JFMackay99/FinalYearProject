extends RefCounted

var x: int
var y: int
var z: int

var tile: Constants.DUNGEON_TILES

func get2dCoordVector():
	return Vector2i(x,y)
	
func get3dCoordVector():
	return Vector3i(x,y,z)
	
func getTile():
	return tile
