extends Node

var maxHeightLayers = 8
var scale = 3

func GenerateUnderground(map: Map) -> void:
	
		# Initialise array holding layers
	var layers = Array()
	layers.resize(maxHeightLayers+1)

	var startLayerConstrunction  = Time.get_ticks_msec()
	
	# Create the first top dungeon layer layer
	var startLayer = DungeonLayer.new(maxHeightLayers, map.overworld.maxX * scale, map.overworld.maxY*scale)
	layers[maxHeightLayers] =startLayer
	
	# Mark the areas of the layer that represents areas of the overworld map that have lower
	# heights than the start layers height
	MarkLayerHeights(map.overworld, startLayer)
	
	var currentLayer :DungeonLayer
	var prevLayer = startLayer
	#Add layers for levels down to 0
	for z in range (maxHeightLayers-1,-1,-1):
		currentLayer = DungeonLayer.new(z, map.overworld.maxX * scale, map.overworld.maxY * scale, prevLayer)
		MarkLayerHeights(map.overworld, currentLayer)
		layers[z] = currentLayer
		prevLayer = currentLayer
	
	var endLayerConstruction = Time.get_ticks_msec()
	var layerConstructionTime = endLayerConstruction-startLayerConstrunction
	print("Layer Construction Time: " +  str(layerConstructionTime) +"ms")
	
	map.dungeon=layers

func MarkLayerHeights(overworld: OverworldMap, layer: DungeonLayer):
	var tile = Constants.DUNGEON_TILES.FORBIDDEN
	for overX in overworld.maxX:
		for overY in overworld.maxY:
			for dX in scale:
				for dY in scale:
					var xCoord = overX * scale + dX
					var yCoord = overY * scale + dY
					if layer.height > overworld.GetHeightAtCellCoordinate(overX, overY):
						
						layer.SetTile(xCoord,yCoord, tile)


#region Parameter Updates

func UpdateMaxHeightLayers(value):
	maxHeightLayers = value

func UpdateScale(value):
	scale = value
