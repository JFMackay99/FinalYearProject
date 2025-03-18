extends Node

var scale = 3
var pathfinder: AStar3D


func GenerateUnderground(map: Map) -> void:
	
	# Initialise array holding layers
	var layers:Array[LayerBase] = []
	layers.resize(Constants.MAX_HEIGHT_LEVELS+1)

	var startLayerConstrunction  = Time.get_ticks_usec()
	
	# Create the first top dungeon layer layer
	var startLayer = UndergroundLayer.new(Constants.MAX_HEIGHT_LEVELS, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y*scale)
	layers[Constants.MAX_HEIGHT_LEVELS] =startLayer
	
	# Mark the areas of the layer that represents areas of the overworld map that have lower
	# heights than the start layers height
	MarkLayerHeights(map.overworld, startLayer)
	
	var currentLayer :LayerBase
	var prevLayer = startLayer
	#Add layers for levels down to 0
	for z in range (Constants.MAX_HEIGHT_LEVELS-1,-1,-1):
		currentLayer = UndergroundLayer.new(z, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y * scale, prevLayer)
		MarkLayerHeights(map.overworld, currentLayer)
		layers[z] = currentLayer
		prevLayer = currentLayer
	
	var endLayerConstruction = Time.get_ticks_usec()
	var layerConstructionTime = endLayerConstruction-startLayerConstrunction
	print("Layer Construction Time: " +  str(layerConstructionTime) +"us")
	
	
	var startPathfindingInitialisation  = Time.get_ticks_usec()
	#Initialise pathfinder
	InitialisePathfinderFromOverworld(map.overworld)
	ConnectPathfinderFromOverworld()
	var endPathfindingInitialisation  = Time.get_ticks_usec()
	var pathfindingInitialisationTime = endPathfindingInitialisation-startPathfindingInitialisation
	map.underground.pathfinderInitialisationTime = pathfindingInitialisationTime
	print("Pathfinder Initialisation time: "+str(pathfindingInitialisationTime)+"us")
	
	map.underground.setLayers(layers)
	

func MarkLayerHeights(overworld: OverworldMap, layer: LayerBase):
	var tile = Constants.DUNGEON_TILES.FORBIDDEN
	for overX in Constants.OVERWORLD_MAX_X:
		for overY in Constants.OVERWORLD_MAX_Y:
			for dX in scale:
				for dY in scale:
					var xCoord = overX * scale + dX
					var yCoord = overY * scale + dY
					if layer.height > overworld.GetHeightAtCellCoordinate(overX, overY):
						
						layer.SetTile(xCoord,yCoord, tile)


# Intialise the pathfinder
func InitialisePathfinderFromOverworld(overworld: OverworldMap):
	pathfinder.clear()
	pathfinder.reserve_space(Constants.MAX_HEIGHT_LEVELS * Constants.OVERWORLD_MAX_X * Constants.OVERWORLD_MAX_Y)
	
	# For each HeightLevel, add cells that would not be Outside
	for z in Constants.MAX_HEIGHT_LEVELS:
		var cost = pathfinder.heightLayerWeightFactor*(Constants.MAX_HEIGHT_LEVELS-z)+1 
		for y in Constants.OVERWORLD_MAX_Y:
			for x in Constants.OVERWORLD_MAX_X:
				var cellHeight = overworld.GetHeightAtCellCoordinate(x, y)
				if cellHeight >= z:
					var location = Vector3(x,y,z)
					var id =pathfinder.CellVectToAStarID(location)
					pathfinder.add_point(id, location, cost)

# Connect the points of the pathfinder
func ConnectPathfinderFromOverworld():
	# Go through each cell that has a point in the pathfinder
	for z in Constants.MAX_HEIGHT_LEVELS:
		for y in Constants.OVERWORLD_MAX_X:
			for x in Constants.OVERWORLD_MAX_Y:
				var locationId = pathfinder.CellCoordsToAStarID(x,y,z)
				if pathfinder.has_point(locationId):
					# Connect adjacent points that will not have been added already
					for neighbourVector in [Vector3(x+1, y, z), Vector3(x,y+1,z), Vector3(x,y,z+1)]:
						var neighbourId = pathfinder.CellVectToAStarID(neighbourVector)
						if pathfinder.has_point(neighbourId):
							pathfinder.connect_points(locationId, neighbourId)


#region Parameter Updates
func UpdateScale(value):
	scale = value
