extends Node

var map: Map

func Generate() -> Map:
	_GenerateOverworld()
	_GenerateDungeon()
	return map

func _GenerateOverworld():
	map.overworld.heights = $OverworldMapGenerator.GenerateMap()
	
func _GenerateDungeon():
	# Generate dungeon entrances
	$DungeonGenerator.RegenerateDungeons() # This is just the entrances
	map.entrances = $DungeonGenerator.entrances
	var startGenerateDungeon = Time.get_ticks_msec()
	# Generate the layers
	var layers = $DungeonGenerator.GenerateDungeonLayers(map.entrances)
	var endGenerateDungeon  = Time.get_ticks_msec()
	var generateDungeonTime = endGenerateDungeon-startGenerateDungeon
	var dungeonLayers = layers
	map.dungeon = layers
