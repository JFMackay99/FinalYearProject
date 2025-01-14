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
		var dungeonEntrance = GetCentralPointFromOverWorldCoords(Vector2i(entrance.x, entrance.y))
		processedEntrances.append(Vector3i(dungeonEntrance.x, dungeonEntrance.y, z))
		layers[z].addEntrance(GetCentralPointFromOverWorldCoords(Vector2(entrance.x, entrance.y)))

	var startPathfindingInitialisation  = Time.get_ticks_msec()
	#Initialise pathfinder
	initialisePathfinder(startLayer)
	connectPathfinder(startLayer)
	var endPathfindingInitialisation  = Time.get_ticks_msec()
	var pathfindingInitialisationTime = endPathfindingInitialisation-startPathfindingInitialisation
	print("Pathfinder Initialisation time: "+str(pathfindingInitialisationTime)+"ms")
	
	#Generate legal route between entrances
	var startPathFinding = Time.get_ticks_msec()
	var path = pathfinder.get_point_path(VectToAStarID(processedEntrances[0]),VectToAStarID(processedEntrances[1]))
	var endPathFinding = Time.get_ticks_msec()
	var pathFindingTime = endPathFinding - startPathFinding
	print("Pathfinding: " + str(pathFindingTime) + "ms")

	var startPathConstruction = Time.get_ticks_msec()
	#Add generated path to layers
	for point in path:
		var zLevel = point.z
		layers[zLevel].setTile(point.x, point.y, Constants.DUNGEON_TILES.ROOM)
	var endPathConstruction  = Time.get_ticks_msec()
	var pathConstructionTime = endPathConstruction - startPathConstruction
	print("Path Construction Time: " + str(pathConstructionTime) + "ms")
	

	var startStairwells = Time.get_ticks_msec()
	#Stairwells
	var sections = ProcessPathIntoHeightSections(path)
	AddConnectingStairwells(layers, sections)
	
	var endStairwells = Time.get_ticks_msec()
	var stairwellTime = endStairwells-startStairwells
	print("Stairwell construction: " +str(stairwellTime) + "ms")



	return layers

# Intialise the pathfinder
func initialisePathfinder(layer : DungeonLayer):
	if pathfinder == null:
		pathfinder = AStar3D.new()
	pathfinder.clear()
	pathfinder.reserve_space((maxMapWidth*dungeonToOverworldScale)*(maxMapHeight*dungeonToOverworldScale)*maxHeightLevels)
	
	# Go through the layers, and add legal tiles to the pathfinder
	var checkedLayer = layer
	var checkedHeight = maxHeightLevels
	while checkedLayer != null:
		for x in layer.mapMaxWidth:
			for y in layer.mapMaxHeight:
				if checkedLayer.map[x][y] != Constants.DUNGEON_TILES.FORBIDDEN:
					var location = Vector3i(x,y,checkedHeight)
					var id = VectToAStarID(location)
					pathfinder.add_point(id, location)
		checkedHeight -=1
		checkedLayer = checkedLayer.LowerLevel


# Connect the points of the pathfinder
func connectPathfinder(layer: DungeonLayer):
	
	var checkedLayer = layer
	var checkedHeight = maxHeightLevels

	#Go through each layer
	while checkedLayer != null:
		#For each tile in layer
		for x in layer.mapMaxWidth:
			for y in layer.mapMaxHeight:
				#Connect to neighbours in layer
				var aStarId = CoordsToAStarID(x,y, checkedHeight)
				if pathfinder.has_point(aStarId):
					for neighbourCoords in [Vector3i(x-1,y, checkedHeight),Vector3i(x+1,y, checkedHeight),Vector3i(x,y-1, checkedHeight),Vector3i(x,y+1, checkedHeight)]:
						var neighbourID = VectToAStarID(neighbourCoords)
						if pathfinder.has_point(neighbourID):
							pathfinder.connect_points(aStarId, neighbourID)
					#if tile is a center point, connect to lower one
					var relevantCenterPoint = GetCentralPointFromDungeonPoint(x,y)
					if Vector2i(x,y)== relevantCenterPoint:
						var lowerID = CoordsToAStarID(x,y,checkedHeight-1)
						if pathfinder.has_point(lowerID):
							pathfinder.connect_points(aStarId, lowerID)
		# Next lower level
		checkedHeight -=1
		checkedLayer = checkedLayer.LowerLevel


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
func AddConnectingStairwells (layers, sections):
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
	var owCoords = GetOverworldCoordsFromDungeonPoint(x,y)
	return GetCentralPointFromOverWorldCoords(owCoords)

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
func GetCentralPointFromOverWorldCoords(owCoords: Vector2i):
	var x = owCoords.x * dungeonToOverworldScale + (dungeonToOverworldScale/2)
	var y =owCoords.y * dungeonToOverworldScale + (dungeonToOverworldScale/2)
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
