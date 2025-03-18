extends RefCounted

class_name MapDetails

var scale: int

var maxHeight: int
var minHeight: int
var aveHeight: int
var totalHeights: int

var biomeCounts: Dictionary
var entrances: Dictionary

var roomCount: int
var pathDistance: int
var availableDistance: int


var pathfindingTime: int
var pathConstructionTime: int
var stairwellConstructionTime: int
var roomConstructionTime: int
var totalDungeonConstructionTime: int
var overworldConstructionTime: int
var undergroundLayerConstructionTime: int
var dungeonLayerConstructionTime: int
var pathfinderInitialisationTime: int
var totalUndergroundConstructionTime: int


func RegisterMapDetails(map: Map):
	
	RegisterOverworld(map.overworld)
	UpdateDungeonDetails(map)

func UpdateDungeonDetails(map: Map):
	entrances.clear()
	
	for i in map.entrances.size():
		var e = map.entrances[i]
		entrances["Entrance "+str(i)] = {
			"x": e.x,
			"y": e.y,
			"z": floor(e.z),
			"biome": Constants.BIOMES.keys()[map.overworld.GetBiomeAtCellCoordinate(e.x,e.y)]
		}
	
	
	scale = map.overworldToDungeonScale
	RegisterUnderground(map.underground)
	RegisterDungeon(map.dungeon)

func RegisterOverworld(overworld: OverworldMap) -> void:
	maxHeight = -1;
	minHeight = Constants.MAX_HEIGHT_LEVELS
	biomeCounts.clear()
	
	overworldConstructionTime=overworld.overworldConstructionTime
	
	
	for x in Constants.OVERWORLD_MAX_X:
		for y in Constants.OVERWORLD_MAX_Y:
			var tileHeight = overworld.GetHeightAtCellCoordinate(x,y)
			var tileBiome = Constants.BIOMES.keys()[overworld.GetBiomeAtCellCoordinate(x,y)]
			if tileHeight > maxHeight:
				maxHeight = tileHeight
			if tileHeight < minHeight:
				minHeight = tileHeight
			totalHeights += tileHeight
			
			if biomeCounts.has(tileBiome):
				biomeCounts[tileBiome] = biomeCounts.get(tileBiome)+1
			else:
				biomeCounts[tileBiome] =1
	aveHeight = totalHeights/(Constants.OVERWORLD_MAX_X*Constants.OVERWORLD_MAX_Y)

func RegisterUnderground(underground: Underground):
	undergroundLayerConstructionTime = underground.layerConstructionTime
	pathfinderInitialisationTime = underground.pathfinderInitialisationTime
	totalUndergroundConstructionTime = underground.totalUndergroundConstructionTime

func RegisterDungeon(dungeon: Dungeon):
	pathfindingTime = dungeon.pathfindingTime
	pathConstructionTime = dungeon.pathConstructionTime
	stairwellConstructionTime = dungeon.stairwellConstructionTime
	roomConstructionTime = dungeon.roomConstructionTime
	totalDungeonConstructionTime = dungeon.totalDungeonConstructionTime
	dungeonLayerConstructionTime = dungeon.dungeonLayerConstructionTime
	
	
	pathDistance = dungeon.pathLength
	roomCount = 0
	for layer: DungeonLayer in dungeon.getLayers():
		roomCount += layer.rooms.size()
		


func ToJSON()-> String:
	var propertiesDictionary = {
		"scale": scale,
		"maxHeight": maxHeight,
		"minHeight": minHeight,
		"aveHeight": aveHeight,
		"totalHeights": totalHeights,
		"biomeCounts": biomeCounts,
		"roomCount": roomCount,
		"pathDistance": pathDistance,
		"availableDistance": availableDistance,
		"entrances": entrances,
		"times": {
			"pathfindingTime": pathfindingTime,
			"pathConstructionTime": pathConstructionTime,
			"stairwellConstructionTime": stairwellConstructionTime,
			"roomConstructionTime": roomConstructionTime,
			"totalDungeonConstructionTime": totalDungeonConstructionTime,
			"overworldConstructionTime": overworldConstructionTime,
			"undergroundLayerConstructionTime": undergroundLayerConstructionTime,
			"dungeonLayerConstructionTime": dungeonLayerConstructionTime,
			"pathfinderInitialisationTime": pathfinderInitialisationTime,
			"totalUndergroundConstructionTime": totalUndergroundConstructionTime,
		},
	}
	
	return JSON.stringify(propertiesDictionary, "\t")
	
			
			
			
		
