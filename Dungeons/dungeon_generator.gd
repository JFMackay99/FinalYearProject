extends Node

#Scale between tiles in the dungeon and overworld
@export var dungeonToOverworldScale = 3

#If an additional layer is needed, how far away the  
@export var maximumDownstairDistance = 5

# Map size parameters
var maxHeightLevels = 8
var maxMapWidth
var maxMapHeight

# Room numbers. Currently unused.
var minRooms = 0
var maxRooms = 0

# Pathfinding algorithm for getting path between entrances
var pathfinder: AStar3D

# Stores the heights of the overworld map
var OverworldHeights : Array

# Stores the three dimensional coordinates of the dungeon entrances
var DungeonEntrances : Array[Vector3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Regenerate the dungeons
func RegenerateDungeons(newHeights: Array, maximumHeightLevels, owHeight, owWidth):
	#Update size parameters
	OverworldHeights = newHeights
	maxHeightLevels = maximumHeightLevels
	maxMapWidth = owWidth * dungeonToOverworldScale
	maxMapHeight = owHeight * dungeonToOverworldScale
	
	# Initialise noise handler to handle rng
	$NoiseHandler.RegenerateNoise()
	seed($NoiseHandler.SeedBuffer)
	
	# Generate Dungeon Entrances
	GenerateDungeonEntrances()

# Generate a number of dungeon entrances, defaulting to 2
func GenerateDungeonEntrances(NumberOfEntrances: int = 2):
	# Clear previous array of entrances
	DungeonEntrances.clear()
	
	# Generate entrances and append to array
	var generatedEntrances = 0
	while generatedEntrances < NumberOfEntrances:
		var entrance = GenerateDungeonEntrance()
		if not DungeonEntrances.has(entrance): 
			DungeonEntrances.append(entrance)
			generatedEntrances+=1
			
# Generate a single dungeon entrance
func GenerateDungeonEntrance():
	# Generate x,y coords of dungeon
	var x = randi_range(0, 63)
	var y = randi_range(0, 63)
	# Get height of entrance
	var z = OverworldHeights[x][y]
	return Vector3(x,y, z)

# Generate dungeon layers between entrances
func GenerateDungeonLayers(entrances: Array):
	# For now assume only two entrances
	
	# Initialise array holding layers
	var layers = Array()
	layers.resize(maxHeightLevels+1)

	var startLayerConstrunction  = Time.get_ticks_msec()
	
	# Create the first top dungeon layer layer
	var startLayer = DungeonLayer.new(maxHeightLevels, maxMapWidth, maxMapHeight)
	layers[maxHeightLevels] =startLayer
	
	# Mark the areas of the layer that represents areas of the overworld map that have lower
	# heights than the start layers height
	startLayer.markHeights(OverworldHeights, dungeonToOverworldScale)
	
	var currentLayer :DungeonLayer
	var prevLayer = startLayer
	#Add layers for levels down to 0
	for z in range (maxHeightLevels-1,-1,-1):
		currentLayer = DungeonLayer.new(z, maxMapWidth, maxMapHeight, prevLayer)
		currentLayer.markHeights(OverworldHeights, dungeonToOverworldScale)
		layers[z] = currentLayer
		prevLayer = currentLayer
	
	var endLayerConstruction = Time.get_ticks_msec()
	var layerConstructionTime = endLayerConstruction-startLayerConstrunction
	print("Layer Construction Time: " +  str(layerConstructionTime) +"ms")
	
	#Add entrances
	var processedEntrances: Array[Vector3i]
	for entrance in entrances:
		var z = floor(entrance.z)
		processedEntrances.append(Vector3i(entrance.x, entrance.y, z))
		layers[z].addEntrance(GetCentralPointFromOverWorldVect(entrance))

	var startPathfindingInitialisation  = Time.get_ticks_msec()
	#Initialise pathfinder
	InitialisePathfinderFromOverworld(OverworldHeights)
	ConnectPathfinderFromOverworld()
	var endPathfindingInitialisation  = Time.get_ticks_msec()
	var pathfindingInitialisationTime = endPathfindingInitialisation-startPathfindingInitialisation
	print("Pathfinder Initialisation time: "+str(pathfindingInitialisationTime)+"ms")
	
	#Generate legal route between entrances
	var startPathFinding = Time.get_ticks_msec()
	var path = pathfinder.get_point_path(CellVectToAStarID(entrances[0]),CellVectToAStarID(entrances[1]))
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
	AddConnectingStairwellsFromOverworldSections(layers, sections)
	
	var endStairwells = Time.get_ticks_msec()
	var stairwellTime = endStairwells-startStairwells
	print("Stairwell construction: " +str(stairwellTime) + "ms")

	
	return layers

# Intialise the pathfinder
func InitialisePathfinderFromOverworld(overworld):
	if pathfinder == null:
		pathfinder = AStar3D.new()
	pathfinder.clear()
	var maxOverworldWidth = overworld.size()
	var maxOverworldHeight = overworld[0].size()
	pathfinder.reserve_space(maxMapHeight * maxOverworldWidth * maxOverworldHeight)
	
	# For each HeightLevel, add cells that would not be Outside
	for z in maxHeightLevels:
		for y in maxOverworldHeight:
			for x in maxOverworldWidth:
				var cellHeight = overworld[x][y]
				if cellHeight >= z:
					var location = Vector3(x,y,z)
					var id =CellVectToAStarID(location)
					pathfinder.add_point(id, location)

# Connect the points of the pathfinder
func ConnectPathfinderFromOverworld():
	# Go through each cell that has a point in the pathfinder
	for z in maxHeightLevels:
		for y in maxMapHeight:
			for x in maxMapWidth:
				var locationId = CellCoordsToAStarID(x,y,z)
				if pathfinder.has_point(locationId):
					# Connect adjacent points that will not have been added already
					for neighbourVector in [Vector3(x+1, y, z), Vector3(x,y+1,z), Vector3(x,y,z+1)]:
						var neighbourId = CellVectToAStarID(neighbourVector)
						if pathfinder.has_point(neighbourId):
							pathfinder.connect_points(locationId, neighbourId)

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

func ConstructDirectionalPathInCell(cell, direction, layer: DungeonLayer):
	var centralPoint = GetCentralPointFromOverWorldCoords(cell.x, cell.y)
	layer.setTile(centralPoint.x, centralPoint.y, Constants.DUNGEON_TILES.ROOM)
	for delta in ceil((dungeonToOverworldScale+1)/2.0):
		match direction:
			Constants.DIRECTION.NORTH: 
				layer.setTile(centralPoint.x, centralPoint.y+delta, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.EAST: 
				layer.setTile(centralPoint.x-delta, centralPoint.y, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.SOUTH: 
				layer.setTile(centralPoint.x, centralPoint.y-delta, Constants.DUNGEON_TILES.ROOM)
			Constants.DIRECTION.WEST: 
				layer.setTile(centralPoint.x+delta, centralPoint.y, Constants.DUNGEON_TILES.ROOM)


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
			
			GenerateDualStairwell(layer, GetCentralPointFromOverWorldVect(section[0]))
		else:
			
			#First Tile stairwell
			#If first section, add up stairs for entrance
			if i == 0:
				GenerateUpStairwell(layer,GetCentralPointFromOverWorldVect(section[0]))
			#Otherwise work out if prev layer is higher or lower for stairwell type
			else:
				var prevHeight = sections[i-1][0].z
				if prevHeight < height:
					GenerateDownStairwell(layer,GetCentralPointFromOverWorldVect(section[0]))
				else:
					GenerateUpStairwell(layer, GetCentralPointFromOverWorldVect(section[0]))
			
			#Last Tile stairwell
			#If last section, add up stairwell for entrance
			if i == sections.size()-1:
				GenerateUpStairwell(layer, GetCentralPointFromOverWorldVect(section[-1]))
			#Otherwise work out if next section is higher or lower
			else: 
				var nextHeight = sections[i+1][0].z
				if nextHeight < height:
					GenerateDownStairwell(layer, GetCentralPointFromOverWorldVect(section[-1]))
				else:
					GenerateUpStairwell(layer, GetCentralPointFromOverWorldVect(section[-1]))



# Generates a stairwell going up
func GenerateUpStairwell(layer, entrance):
	var startX = entrance.x - (dungeonToOverworldScale-1)/2
	var startY = entrance.y - (dungeonToOverworldScale-1)/2
	GenerateSquareRoom(layer, startX, startY, dungeonToOverworldScale)
	layer.setTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.UP_STAIRS)

# Generates a stairwell going down	
func GenerateDownStairwell(layer, entrance):
	var startX = entrance.x - (dungeonToOverworldScale-1)/2
	var startY = entrance.y - (dungeonToOverworldScale-1)/2
	GenerateSquareRoom(layer, startX, startY, dungeonToOverworldScale)
	layer.setTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.DOWN_STAIRS)

# Generates a stairwell going both up and down
func GenerateDualStairwell(layer, entrance):
	var startX = entrance.x - (dungeonToOverworldScale-1)/2
	var startY = entrance.y - (dungeonToOverworldScale-1)/2
	GenerateSquareRoom(layer, startX, startY, dungeonToOverworldScale)
	layer.setTile(entrance.x, entrance.y, Constants.DUNGEON_TILES.DUAL_STAIRS)

# Generates a square room
func GenerateSquareRoom(layer: DungeonLayer, xStart: int, yStart: int, width: int):
	GenerateRectangleRoom(layer, xStart, yStart, width, width)

# Generates a rectangle room
func GenerateRectangleRoom(layer: DungeonLayer, xStart: int, yStart: int, width: int, height: int):
	for x in width:
		for y in width:
			layer.setTile(xStart+x, yStart+y, Constants.DUNGEON_TILES.ROOM)

# For a given point in a dungeon layer, gets the central point of the corresponding overworld coordinate
func GetCentralPointFromDungeonPoint(x,y):
	var owVect = GetOverworldCoordsFromDungeonPoint(x,y)
	return GetCentralPointFromOverWorldVect(owVect)

# Gets an area of the dungeon layer that corresponds to the given overworld coordinates
func GetDungeonAreaFromOverworldCoords(owCoords):
	var area = Array()
	for i in dungeonToOverworldScale:
		area.append([])
		for j in dungeonToOverworldScale:
			area.append(Vector2(owCoords.x*dungeonToOverworldScale +i, owCoords.y*dungeonToOverworldScale + j))
	return area

# Gets the central point of an area of the dungeon layers that correspond to the given overworld
# coordinates
func GetCentralPointFromOverWorldVect(cellVect):
	return GetCentralPointFromOverWorldCoords(cellVect.x, cellVect.y)
	
func GetCentralPointFromOverWorldCoords(cellX, cellY):
	var x = cellX * dungeonToOverworldScale + (dungeonToOverworldScale/2)
	var y = cellY * dungeonToOverworldScale + (dungeonToOverworldScale/2)
	return Vector2i(x, y)
	


# Gets the overworld coordinates corresponding to a given point in a dungeon layer
func GetOverworldCoordsFromDungeonPoint(x,y):
	return Vector2(x/dungeonToOverworldScale, y/dungeonToOverworldScale)

# Updates the seed buffer
func UpdateSeedValue(value: float) -> void:
	$NoiseHandler.SeedBuffer = value

# Updates the dungeon to overworld scale
func UpdateScale(value: float) -> void:
	dungeonToOverworldScale = value

# Updates the minimum number of rooms
func UpdateMinRooms(value: float) -> void:
	minRooms = value

# Update the maximum number of rooms
func UpdateMaxRooms(value: float) -> void:
	maxRooms = value

# Gets the ID corresponding to the given coordinates given as a vector
func VectToAStarID(vector : Vector3i):
	return CoordsToAStarID(vector.x, vector.y, vector.z)
# Gets the ID corresponding to the given coordinates given as individual coordinates
func CoordsToAStarID(x: int, y: int, z:int) -> int:
	return z*(maxMapHeight * maxMapWidth) + (y * maxMapWidth) + x

func CellVectToAStarID(vector : Vector3):
	return CellCoordsToAStarID(vector.x, vector.y, vector.z)

func CellCoordsToAStarID(x: int, y: int, z: int):
	return floor(z)*(OverworldHeights.size()*OverworldHeights[0].size())+y*OverworldHeights.size() +x
