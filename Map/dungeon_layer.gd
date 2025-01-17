extends RefCounted

class_name DungeonLayer

var height: int

var map : Array
var mapMaxWidth:int
var mapMaxHeight:int


var stairsUp : Array
var stairsDown: Array

var HigherLevel: DungeonLayer = null
var LowerLevel: DungeonLayer = null


func _init(layerHeight: int, maxWidth, maxHeight, higherLevel: DungeonLayer = null) -> void:
	self.height = layerHeight
	if higherLevel != null:
		self.HigherLevel = higherLevel
		higherLevel.LowerLevel = self
		
	#initialise map
	map = Array()
	for x in maxWidth:
		map.append([])
		for y in maxHeight:
			map[x].append(Constants.DUNGEON_TILES.ROCK)

	mapMaxHeight = maxHeight
	mapMaxWidth = maxWidth
	
func addEntrance(entrance):
	stairsUp.append(Vector2i(entrance.x, entrance.y))

func setTile(x: int, y: int, tile: int):
	map[x][y] = tile

	
