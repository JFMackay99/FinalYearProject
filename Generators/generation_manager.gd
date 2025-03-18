extends Node

## Overall Map
var map: Map
var mapDetails: MapDetails


var scaleChanged = false



## Constructor
func _ready() -> void:
	map = Map.new()
	mapDetails = MapDetails.new()
	
	var pathfinder = ModifiedAStar3D.new()
	$UndergroundGenerator.pathfinder = pathfinder
	$DungeonGenerator.pathfinder = pathfinder
	

## Generate Map 
func Generate() -> Map:
	_GenerateOverworld()
	_GenerateUnderground()
	_GenerateDungeon()
	
	mapDetails.RegisterMapDetails(map)
	print(mapDetails.ToJSON())
	return map

## Regenerate Dungeon layer
func RegenerateDungeon() -> Map:
	if scaleChanged:
		_GenerateUnderground()
		scaleChanged = false
	
	_GenerateDungeon()
	
	mapDetails.UpdateDungeonDetails(map)
	print(mapDetails.ToJSON())
	return map

## Generate the Overworld layer
func _GenerateOverworld() -> void:
	var startOverworldGeneration = Time.get_ticks_msec()
	$OverworldMapGenerator.GenerateMap(map.overworld)
	var endOverworldGeneration = Time.get_ticks_msec()
	var overworldGenerationTime = endOverworldGeneration - startOverworldGeneration
	map.overworld.overworldConstructionTime = overworldGenerationTime
	print("Overworld Map Generation Time: " + str(overworldGenerationTime)+ "us")

## Generate the Underground Layers
func _GenerateUnderground() -> void:
	var startUndergroundGeneration = Time.get_ticks_msec()
	$UndergroundGenerator.GenerateUnderground(map)
	var endUndergroundGeneration = Time.get_ticks_msec()
	var undergroundGenerationTime = endUndergroundGeneration - startUndergroundGeneration
	map.underground.totalUndergroundConstructionTime = undergroundGenerationTime
	print("Underground Genration Time: " + str(undergroundGenerationTime) + "us")

## Generate the Dungeon Layers
func _GenerateDungeon() -> void:
	var startDungeonGeneration = Time.get_ticks_msec()
	# Generate dungeon entrances
	$DungeonGenerator.RegenerateDungeons(map)
	
	var endDungeonGeneration = Time.get_ticks_msec()
	var dungeonGenerationTime = endDungeonGeneration - startDungeonGeneration
	map.dungeon.totalDungeonConstructionTime = dungeonGenerationTime
	print("Dungeon Map Generation Time: " + str(dungeonGenerationTime)+ "us")


#region Parameter Update

func UpdateHeightChangeWeightSelector(value: float) -> void:
	$DungeonGenerator.UpdateHeightChangeCostFactor(value)

func UpdateHeightLayerWeightSelector(value: float) -> void:
	$DungeonGenerator.UpdateHeightLayerWeightFactor(value)

func UpdateMaxRooms(value: float) -> void:
	$DungeonGenerator.UpdateMaxRooms(value)

func UpdateMinRooms(value: float) -> void:
	$DungeonGenerator.UpdateMinRooms(value)

func UpdateMaxRoomCells(value: float):
	$DungeonGenerator.UpdateMaxRoomCells(value)

func UpdateMinRoomCells(value: float):
	$DungeonGenerator.UpdateMinRoomCells(value)

func UpdateScale(value: float) -> void:
	scaleChanged = true
	$DungeonGenerator.UpdateScale(value)
	$UndergroundGenerator.UpdateScale(value)
	map.overworldToDungeonScale= value

func UpdateDungeonSeed(value: float) -> void:
	$DungeonGenerator.UpdateSeedValue(value)


func UpdateHeightNoiseFrequency(value: float) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseFrequency(value)

func UpdateHeightNoiseSeed(value: float) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseSeed(value)

func UpdateHeightNoiseType(index: int) -> void:
	$OverworldMapGenerator.UpdateHeightNoiseType(index)

func UpdateBiomeNoiseFrequency(value: float) -> void:
	$OverworldMapGenerator.UpdateBiomeNoiseFrequency(value)

func UpdateBiomeNoiseSeed(value: float) -> void:
	$OverworldMapGenerator.UpdateBiomeNoiseSeed(value)

func UpdateBiomeNoiseType(index: int) -> void:
	$OverworldMapGenerator.UpdateBiomeNoiseType(index)
#endregion



func UpdateSelectedRoomGenerator(index: int) -> void:
	$DungeonGenerator.UpdateSelectedRoomGenerator(index)
