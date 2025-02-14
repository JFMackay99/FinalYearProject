extends Node

#Scale between tiles in the dungeon and overworld
@export var scale = 3

# Random Number Generator
var rng: RandomNumberGenerator
var seed = 0

# Map size parameters
var maxMapWidth
var maxMapHeight

# Pathfinding weight factor for lower levels: cost is Weight*(maxHeights+1-layerHeight)
var heightLayerWeightFactor = 10

# Pathfinding weight factor for changing height layers
var heightChangeCostFactor = 10


# Pathfinding algorithm for getting path between entrances
var pathfinder: ModifiedAStar3D


# Stores the three dimensional coordinates of the dungeon entrances
var DungeonEntrances : Array[Vector3]

# Room Generators
var RoomGenerators : Array[RoomGeneratorBase]
var SelectedRoomGenerator : RoomGeneratorBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# 0: No Rooms
	RoomGenerators.append(RoomGeneratorBase.new())
	# 1: Basic
	RoomGenerators.append(BasicRoomGenerator.new())
	
	rng = RandomNumberGenerator.new()
	RoomGeneratorBase.rng = rng
	
	SelectedRoomGenerator = RoomGenerators[0]

# Regenerate the dungeons
func RegenerateDungeons(map: Map):
	#Update size parameters
	maxMapWidth = Constants.OVERWORLD_MAX_X * scale
	maxMapHeight = Constants.OVERWORLD_MAX_Y * scale
	
	# Initialise noise handler to handle rng
	$NoiseHandler.RegenerateNoise()
	seed($NoiseHandler.SeedBuffer)
	rng.seed = seed
	
	# Generate Dungeon Entrances
	GenerateDungeonEntrances(map)
	GenerateDungeonLayers(map)

# Generate a number of dungeon entrances, defaulting to 2
func GenerateDungeonEntrances(map: Map, NumberOfEntrances: int = 2):
	# Clear previous array of entrances
	DungeonEntrances.clear()
	
	# Generate entrances and append to array
	var generatedEntrances = 0
	while generatedEntrances < NumberOfEntrances:
		var entrance = GenerateDungeonEntrance(map)
		if not DungeonEntrances.has(entrance): 
			DungeonEntrances.append(entrance)
			generatedEntrances+=1
	map.entrances = DungeonEntrances

# Generate a single dungeon entrance
func GenerateDungeonEntrance(map: Map):
	# Generate x,y coords of dungeon
	var x = randi_range(0, 63)
	var y = randi_range(0, 63)
	# Get height of entrance
	var z = map.overworld.GetHeightAtCellCoordinate(x,y)
	return Vector3(x,y, z)

# Generate dungeon layers between entrances
func GenerateDungeonLayers(map: Map):
	scale = map.overworldToDungeonScale
	var layers:Array[LayerBase] = []
	map.dungeon.setLayers(layers)
	layers.resize(Constants.MAX_HEIGHT_LEVELS+1)

	var startLayerConstrunction  = Time.get_ticks_msec()
	
	# Create the first top dungeon layer layer
	var startLayer = DungeonLayer.new(Constants.MAX_HEIGHT_LEVELS, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y*scale)
	layers[Constants.MAX_HEIGHT_LEVELS] =startLayer
	
	
	var currentLayer :LayerBase
	var prevLayer = startLayer
	#Add layers for levels down to 0
	for z in range (Constants.MAX_HEIGHT_LEVELS-1,-1,-1):
		currentLayer = DungeonLayer.new(z, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y * scale, prevLayer)
	
		layers[z] = currentLayer
		prevLayer = currentLayer
	
	var endLayerConstruction = Time.get_ticks_msec()
	var layerConstructionTime = endLayerConstruction-startLayerConstrunction
	print("Layer Construction Time: " +  str(layerConstructionTime) +"ms")
	#Add entrances
	var entrances = map.entrances
	
	var processedEntrances: Array[Vector3i]
	for entrance in entrances:
		var z = floor(entrance.z)
		processedEntrances.append(Vector3i(entrance.x, entrance.y, z))
		#map.dungeon[z].addEntrance(UtilityMethods.GetCentralPointFromOverWorldVect(entrance, scale))

	
	#Generate legal route between entrances
	var startPathFinding = Time.get_ticks_msec()
	var path = pathfinder.get_point_path(pathfinder.CellVectToAStarID(entrances[0]), pathfinder.CellVectToAStarID(entrances[1]))
	var endPathFinding = Time.get_ticks_msec()
	var pathFindingTime = endPathFinding - startPathFinding
	print("Pathfinding: " + str(pathFindingTime) + "ms")

	var startPathConstruction = Time.get_ticks_msec()
	#Add generated path to layers
	ConstructCellPathBetweenEntrancesInDungeon(path, layers)
	var endPathConstruction  = Time.get_ticks_msec()
	var pathConstructionTime = endPathConstruction - startPathConstruction
	print("Path Construction Time: " + str(pathConstructionTime) + "ms")
	
	
	
	var startStairwells = Time.get_ticks_msec()
	#Stairwells
	var sections = ProcessPathIntoHeightSections(path)
	
	SelectedRoomGenerator.AddConnectingStairwellsFromOverworldSections(map.dungeon.dungeonLayers, sections)
	SelectedRoomGenerator.GenerateRooms(map, sections)
	
	var endStairwells = Time.get_ticks_msec()
	var stairwellTime = endStairwells-startStairwells
	print("Stairwell construction: " +str(stairwellTime) + "ms")
	
	for layer in layers:
		layer.ConstructRooms()


func ConstructCellPathBetweenEntrancesInDungeon(path: Array, layers: Array):
	
	# Construct first cell
	var startCell = path[0]
	var nextCell = path[1]
	# Work out direction of path, path routes are strictly orthogonal
	var direction = CalculateDirectionFromOrthogonalCoords(startCell, nextCell)
	ConstructDirectionalPathInCell(startCell, direction, layers[startCell.z])
	
	#Construct last Cell
	var endCell = path[-1]
	var prevCell = path[-2]
	direction = CalculateDirectionFromOrthogonalCoords(endCell, prevCell)
	ConstructDirectionalPathInCell(endCell, direction, layers[endCell.z])
	
	#Construct other cells
	for i in range(1, path.size()-1):
		var cell = path[i]
		prevCell = path[i-1]
		nextCell = path[i+1]
		direction = CalculateDirectionFromOrthogonalCoords(cell, prevCell)
		ConstructDirectionalPathInCell(cell, direction, layers[cell.z])
		direction = CalculateDirectionFromOrthogonalCoords(cell, nextCell)
		ConstructDirectionalPathInCell(cell, direction, layers[cell.z])
		

func CalculateDirectionFromOrthogonalCoords(from, to):
	if from.x != to.x:
		if from.x < to.x:
			return Constants.DIRECTION.WEST
		else:
			return Constants.DIRECTION.EAST
	if from.y != to.y:
		if from.y < to.y:
			return Constants.DIRECTION.NORTH
		else:
			return Constants.DIRECTION.SOUTH
	if from.z != to.z:
		if from.z < to.y:
			return Constants.DIRECTION.UP
		else:
			return Constants.DIRECTION.DOWN
	
	return Constants.DIRECTION.SAME

func ConstructDirectionalPathInCell(cell, direction, layer: LayerBase):
	var centralPoint = UtilityMethods.GetCentralPointFromOverWorldCoords(cell.x, cell.y, scale)
	layer.SetTile(centralPoint.x, centralPoint.y, Constants.DUNGEON_TILES.ROOM)
	for delta in ceil((scale+1)/2.0):
		match direction:
			Constants.DIRECTION.NORTH: 
				layer.SetTile(centralPoint.x, centralPoint.y+delta, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.EAST: 
				layer.SetTile(centralPoint.x-delta, centralPoint.y, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.SOUTH: 
				layer.SetTile(centralPoint.x, centralPoint.y-delta, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.WEST: 
				layer.SetTile(centralPoint.x+delta, centralPoint.y, Constants.DUNGEON_TILES.ROOM)


# Seperate the path into sections that are on the same layer
func ProcessPathIntoHeightSections(path):
	var pathSections = Array()
	var activeSection = Array()
	var currentZ = path[0].z
	
	for tile in path:
		if currentZ != tile.z:
			# If the tile is not the currently checked height, go onto the next section
			pathSections.append(activeSection)
			activeSection = Array()
			activeSection.append(tile)
			currentZ = tile.z
		else:
			activeSection.append(tile)
	
	#Add final section
	pathSections.append(activeSection)
	return pathSections

# Reconnect a path that has been seperated into sections of the same layer
func ReconnectPathHeightSectionsIntoPath(pathHeightSections):
	var path = Array()
	for section in pathHeightSections:
			path.append_array(section)
			
	return path


# Updates the seed buffer
func UpdateSeedValue(value: float) -> void:
	seed =value
	$NoiseHandler.SeedBuffer = value

# Updates the dungeon to overworld scale
func UpdateScale(value: float) -> void:
	for roomGenerator in RoomGenerators:
		roomGenerator.scale = value
	scale = value

# Updates the minimum number of rooms
func UpdateMinRooms(value: float) -> void:
	RoomGeneratorBase.minRooms

# Update the maximum number of rooms
func UpdateMaxRooms(value: float) -> void:
	RoomGeneratorBase.maxRooms = value
	
# Updates the minimum size of rooms
func UpdateMinRoomCells(value: float) -> void:
	RoomGeneratorBase.minRoomCells

# Update the maximum size of rooms
func UpdateMaxRoomCells(value: float) -> void:
	RoomGeneratorBase.maxRooms = value

func UpdateHeightLayerWeightFactor(value):
	heightLayerWeightFactor = value
	pathfinder.heightLayerWeightFactor = value
	
func UpdateHeightChangeCostFactor(value):
	heightChangeCostFactor = value
	pathfinder.heightChangeCostFactor = value
	
func UpdateSelectedRoomGenerator(index: int):
	SelectedRoomGenerator = RoomGenerators[index]
