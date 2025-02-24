extends LayerBase

class_name UndergroundLayer

var map: Array

func _init(layerHeight: int, maxWidth, maxHeight, higherLevel: LayerBase = null) -> void:
	super._init(layerHeight, maxWidth, maxHeight, higherLevel)
		
	#initialise map
	map = Array()
	for x in maxWidth:
		map.append([])
		for y in maxHeight:
			map[x].append(Constants.DUNGEON_TILES.ROCK)

	mapMaxHeight = maxHeight
	mapMaxWidth = maxWidth

func GetTile( x, y) -> Constants.DUNGEON_TILES:
	# If outside of bounds return FORBIDDEN
	if x >= mapMaxWidth || y >= mapMaxHeight || x < 0 || y < 0:
		return Constants.DUNGEON_TILES.FORBIDDEN
	
	return map[x][y]
	
func GetTileFromVect(point)-> Constants.DUNGEON_TILES:
	return GetTile(point.x, point.y)

func SetTile(x: int, y: int, tile: int):
	map[x][y] = tile
