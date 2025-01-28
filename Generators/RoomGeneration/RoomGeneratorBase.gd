extends Node

class_name RoomGeneratorBase

var scale = 3
var noiseHandler : NoiseHandler


func GenerateRoom(map: Map, sections: Array):
	pass

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
