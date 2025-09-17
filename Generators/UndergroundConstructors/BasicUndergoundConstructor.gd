extends Object

class_name BasicUndergroundConstructor

static var scale = 3;

func MarkAllLayerHeights(overworld : OverworldMap, layers : Array[LayerBase]):
	
	var startLayer: LayerBase = layers[Constants.MAX_HEIGHT_LEVELS]
	
	# Mark the areas of the layer that represents areas of the overworld map that have lower
	# heights than the start layers height
	MarkLayerHeights(overworld, startLayer)
	
	var currentLayer :LayerBase
	#Add layers for levels down to 0
	for z in range (Constants.MAX_HEIGHT_LEVELS-1,-1,-1):
		currentLayer = UndergroundLayer.new(z, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y * scale)
		MarkLayerHeights(overworld, currentLayer)
		layers[z] = currentLayer



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
