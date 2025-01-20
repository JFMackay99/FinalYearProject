extends LayerBase

class_name UndergroundLayer

var map: Array

func _init(layerHeight: int, maxWidth, maxHeight, higherLevel: DungeonLayer = null) -> void:
	super._init(layerHeight, maxWidth, maxHeight, higherLevel)
		
	#initialise map
	map = Array()
	for x in maxWidth:
		map.append([])
		for y in maxHeight:
			map[x].append(Constants.DUNGEON_TILES.ROCK)

	mapMaxHeight = maxHeight
	mapMaxWidth = maxWidth

func GetTile( x, y):
	return map[x][y]

func SetTile(x: int, y: int, tile: int):
	map[x][y] = tile
