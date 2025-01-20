extends LayerBase

class_name DungeonLayerLegacy


var map : Array


var stairsUp : Array
var stairsDown: Array



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
	
func addEntrance(entrance):
	stairsUp.append(Vector2i(entrance.x, entrance.y))

func SetTile(x: int, y: int, tile: int):
	map[x][y] = tile

	
