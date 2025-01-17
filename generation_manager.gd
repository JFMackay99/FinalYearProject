extends Node

var map: Map
var maxHeightLevels: int

func _init() -> void:
	map = Map.new()

func Generate() -> Map:
	var startOverworldGeneration = Time.get_ticks_msec()
	_GenerateOverworld()
	var endOverworldGeneration = Time.get_ticks_msec()
	var overworldGenerationTime = endOverworldGeneration - startOverworldGeneration
	print("Overworld Map Generation Time: " + str(overworldGenerationTime)+ "ms")
	
	var startDungeonGeneration = Time.get_ticks_msec()
	_GenerateDungeon()
	var endDungeonGeneration = Time.get_ticks_msec()
	var dungeonGenerationTime = endDungeonGeneration - startDungeonGeneration
	print("Dungeon Map Generation Time: " + str(dungeonGenerationTime)+ "ms")
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


func UpdateHeightChangeWeightSelector(value: float) -> void:
	$DungeonGenerator.UpdateHeightChangeCostFactor(value)

func UpdateHeightLayerWeightSelector(value: float) -> void:
	$DungeonGenerator.UpdateHeightLayerWeightFactor(value)

func UpdateMaxRooms(value: float) -> void:
	$DungeonGenerator.UpdateMaxRooms(value)

func UpdateMinRooms(value: float) -> void:
	$DungeonGenerator.UpdateMinRooms(value)

func UpdateScale(value: float) -> void:
	$DungeonGenerator.UpdateScale(value)

func UpdateDungeonSeed(value: float) -> void:
	$DungeonGenerator.UpdateSeedValue(value)


func UpdateHeightNoiseFrequency(value: float) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseFrequency(value)

func UpdateHeightNoiseSeed(value: float) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseSeed(value)

func UpdateHeightNoiseType(index: int) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseType(index)
