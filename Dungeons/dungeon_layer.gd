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

var minX =-1
var maxX =-1
var minY =-1
var maxY =-1


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
	#Update min/max values if tile is non-empty
	if tile != Constants.DUNGEON_TILES.ROCK and tile != Constants.DUNGEON_TILES.FORBIDDEN:
		if minX > x or minX == -1:
			minX = x
		if minY > y or minY == -1:
			minY = y
		if maxX < x:
			maxX = x
		if maxY < y:
			maxY = y
	map[x][y] = tile
	
func markHeights(overworldHeight: Array, dtoScale: int):
	
	var tile = Constants.DUNGEON_TILES.FORBIDDEN
	for overX in overworldHeight.size():
		for overY in overworldHeight[overX].size():
			for dX in dtoScale:
				for dY in dtoScale:
					var xCoord = overX * dtoScale + dX
					var yCoord = overY * dtoScale + dY
					if height > overworldHeight[overX][overY]:
						
						setTile(xCoord,yCoord, tile)

func vectorToAStarID(coord: Vector2i):
	return coordToAStarID(coord.x, coord.y)

func coordToAStarID(x: int, y: int) -> int:
	return x*mapMaxHeight + y
