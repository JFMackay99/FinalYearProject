extends Node

#Scale between tiles in the dungeon and overworld
@export var scale = 3


# Map size parameters
var maxMapWidth
var maxMapHeight

# Pathfinding weight factor for lower levels: cost is Weight*(maxHeights+1-layerHeight)
var heightLayerWeightFactor = 10

# Pathfinding weight factor for changing height layers
var heightChangeCostFactor = 10

# Room numbers. Currently unused.
var minRooms = 0
var maxRooms = 0

# Pathfinding algorithm for getting path between entrances
var pathfinder: AStar3D


# Stores the three dimensional coordinates of the dungeon entrances
var DungeonEntrances : Array[Vector3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Regenerate the dungeons
func RegenerateDungeons(map: Map):
	#Update size parameters
	maxMapWidth = Constants.OVERWORLD_MAX_X * scale
	maxMapHeight = Constants.OVERWORLD_MAX_Y * scale
	
	# Initialise noise handler to handle rng
	$NoiseHandler.RegenerateNoise()
	seed($NoiseHandler.SeedBuffer)
	
	# Generate Dungeon Entrances
	GenerateDungeonEntrances(map)

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
	var scale = map.overworldToDungeonScale
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
	AddConnectingStairwellsFromOverworldSections(map.dungeon.dungeonLayers, sections)
	
	var endStairwells = Time.get_ticks_msec()
	var stairwellTime = endStairwells-startStairwells
	print("Stairwell construction: " +str(stairwellTime) + "ms")


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


# Adds stairwells between sections.
func AddConnectingStairwellsFromUndergroundSections (layers, sections):
	# For each section
	for i in sections.size():
		var section = sections[i]
		var height =section[0].z
		var layer =  layers[height]
		#If single tile, so going staright down/up, add a dual stairwell
		if section.size() == 1:
			GenerateDualStairwell(layer, section[0])
		else:
			
			#First Tile stairwell
			#If first section, add up stairs for entrance
			if i == 0:
				GenerateUpStairwell(layer,section[0])
			#Otherwise work out if prev layer is higher or lower for stairwell type
			else:
				var prevHeight = sections[i-1][0].z
				if prevHeight < height:
					GenerateDownStairwell(layer,section[0])
				else:
					GenerateUpStairwell(layer, section[0])
			
			#Last Tile stairwell
			#If last section, add up stairwell for entrance
			if i == sections.size()-1:
				GenerateUpStairwell(layer, section[-1])
			#Otherwise work out if next section is higher or lower
			else: 
				var nextHeight = sections[i+1][0].z
				if nextHeight < height:
					GenerateDownStairwell(layer, section[-1])
				else:
					GenerateUpStairwell(layer, section[-1])

func AddConnectingStairwellsFromOverworldSections (layers, sections):
	# For each section
	for i in sections.size():
		var section = sections[i]
		var height =section[0].z
		var layer =  layers[height]
		#If single tile, so going staright down/up, add a dual stairwell
		if section.size() == 1:
			
			GenerateDualStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
		else:
			
			#First Tile stairwell
			#If first section, add up stairs for entrance
			if i == 0:
				GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
			#Otherwise work out if prev layer is higher or lower for stairwell type
			else:
				var prevHeight = sections[i-1][0].z
				if prevHeight < height:
					GenerateDownStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
				else:
					GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
			
			#Last Tile stairwell
			#If last section, add up stairwell for entrance
			if i == sections.size()-1:
				GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))
			#Otherwise work out if next section is higher or lower
			else: 
				var nextHeight = sections[i+1][0].z
				if nextHeight < height:
					GenerateDownStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))
				else:
					GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))



# Generates a stairwell going up
func GenerateUpStairwell(layer, entrance):
	var startX = entrance.x - (scale-1)/2
	var startY = entrance.y - (scale-1)/2
	GenerateSquareRoom(layer, startX, startY, scale)
	layer.SetTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.UP_STAIRS)

# Generates a stairwell going down	
func GenerateDownStairwell(layer, entrance):
	var startX = entrance.x - (scale-1)/2
	var startY = entrance.y - (scale-1)/2
	GenerateSquareRoom(layer, startX, startY, scale)
	layer.SetTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.DOWN_STAIRS)

# Generates a stairwell going both up and down
func GenerateDualStairwell(layer, entrance):
	var startX = entrance.x - (scale-1)/2
	var startY = entrance.y - (scale-1)/2
	GenerateSquareRoom(layer, startX, startY, scale)
	layer.SetTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.DUAL_STAIRS)

# Generates a square room
func GenerateSquareRoom(layer: LayerBase, xStart: int, yStart: int, width: int):
	GenerateRectangleRoom(layer, xStart, yStart, width, width)

# Generates a rectangle room
func GenerateRectangleRoom(layer: LayerBase, xStart: int, yStart: int, width: int, height: int):
	for x in width:
		for y in width:
			layer.SetTile(xStart+x, yStart+y, Constants.DUNGEON_TILES.ROOM)


# Updates the seed buffer
func UpdateSeedValue(value: float) -> void:
	$NoiseHandler.SeedBuffer = value

# Updates the dungeon to overworld scale
func UpdateScale(value: float) -> void:
	scale = value

# Updates the minimum number of rooms
func UpdateMinRooms(value: float) -> void:
	minRooms = value

# Update the maximum number of rooms
func UpdateMaxRooms(value: float) -> void:
	maxRooms = value



func UpdateHeightLayerWeightFactor(value):
	heightLayerWeightFactor = value
	
func UpdateHeightChangeCostFactor(value):
	heightChangeCostFactor = value
	pathfinder.heightChangeCostFactor = value




	
