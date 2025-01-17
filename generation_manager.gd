extends Node

var map: Map
var maxHeightLevels: int

func _init() -> void:
	map = Map.new()

func Generate() -> Map:
	_GenerateOverworld()
	_GenerateDungeon()
	return map

func RegenerateDungeon() -> Map:
	_GenerateDungeon()
	return map

func UpdateMaxHeightLevels(value) -> void:
	maxHeightLevels = value
	$OverworldMapGenerator.maxHeightLevels = value
	$DungeonGenerator.maxHeightLevels = value

func _GenerateOverworld() -> void:
	map.overworld.heights = $OverworldMapGenerator.GenerateMap()
	
func _GenerateDungeon() -> void:
	# Generate dungeon entrances
	$DungeonGenerator.RegenerateDungeons(map.overworld.heights, maxHeightLevels, map.overworld.maxX, map.overworld.maxY) # This is just the entrances
	map.entrances = $DungeonGenerator.DungeonEntrances
	var startGenerateDungeon = Time.get_ticks_msec()
	# Generate the layers
	var layers = $DungeonGenerator.GenerateDungeonLayers(map.entrances)
	var endGenerateDungeon  = Time.get_ticks_msec()
	var generateDungeonTime = endGenerateDungeon-startGenerateDungeon
	var dungeonLayers = layers
	map.dungeon = layers
