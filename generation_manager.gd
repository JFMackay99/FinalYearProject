extends Node

## Overall Map
var map: Map
## Maximum number of height layers
var maxHeightLevels: int

## Constructor
func _init() -> void:
	map = Map.new()

## Generate Map 
func Generate() -> Map:
	_GenerateOverworld()
	_GenerateDungeon()
	return map

## Regenerate Dungeon layer
func RegenerateDungeon() -> Map:
	_GenerateDungeon()
	return map

## Generate the Overworld layer
func _GenerateOverworld() -> void:
	var startOverworldGeneration = Time.get_ticks_msec()
	map.overworld.heights = $OverworldMapGenerator.GenerateMap()
	var endOverworldGeneration = Time.get_ticks_msec()
	var overworldGenerationTime = endOverworldGeneration - startOverworldGeneration
	print("Overworld Map Generation Time: " + str(overworldGenerationTime)+ "ms")

## Generate the Dungeon Layers
func _GenerateDungeon() -> void:
	var startDungeonGeneration = Time.get_ticks_msec()
	# Generate dungeon entrances
	$DungeonGenerator.RegenerateDungeons(map.overworld.heights, maxHeightLevels, map.overworld.maxX, map.overworld.maxY) # This is just the entrances
	map.entrances = $DungeonGenerator.DungeonEntrances
	# Generate the layers
	var layers = $DungeonGenerator.GenerateDungeonLayers(map.entrances)
	map.dungeon = layers
	
	var endDungeonGeneration = Time.get_ticks_msec()
	var dungeonGenerationTime = endDungeonGeneration - startDungeonGeneration
	print("Dungeon Map Generation Time: " + str(dungeonGenerationTime)+ "ms")


#region Parameter Update
func UpdateMaxHeightLevels(value) -> void:
	maxHeightLevels = value
	$OverworldMapGenerator.maxHeightLevels = value
	$DungeonGenerator.maxHeightLevels = value

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
#endregion
