extends Node

class_name RoomGeneratorBase

var decorator: DecoratorBase 

var scale = 3

static var rng: RandomNumberGenerator

# Room numbers
static var minRooms = 1
static var maxRooms = 3

# Room Size parameters
static var maxRoomCells = 3
static var minRoomCells = 1

func _init(decorator: DecoratorBase = null) -> void:
	self.decorator=decorator

func GenerateRooms(map: Map, sections: Array):
	pass

func AddConnectingStairwellsFromOverworldSections (layers, sections):
	# For each section
	for i in sections.size():
		var section = sections[i]
		var height =section[0].z
		var layer =  layers[height]
		var stairwell: SquareStairwell
		#If single tile, so going staright down/up, add a dual stairwell
		if section.size() == 1:
			
			GenerateDualStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
		else:
			
			#First Tile stairwell
			#If first section, add up stairs for entrance
			if i == 0:
				stairwell = GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
			#Otherwise work out if prev layer is higher or lower for stairwell type
			else:
				var prevHeight = sections[i-1][0].z
				if prevHeight < height:
					stairwell = GenerateDownStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
				else:
					stairwell = GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[0], scale))
			stairwell.AddDoors(section, 0, scale)
			
			#Last Tile stairwell
			#If last section, add up stairwell for entrance
			if i == sections.size()-1:
				stairwell = GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))
			#Otherwise work out if next section is higher or lower
			else: 
				var nextHeight = sections[i+1][0].z
				if nextHeight < height:
					stairwell = GenerateDownStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))
				else:
					stairwell = GenerateUpStairwell(layer, UtilityMethods.GetCentralPointFromOverWorldVect(section[-1], scale))
				
			stairwell.AddDoors(section, section.size()-1, scale)

func GetSectionsLargeEnoughForARoom(sections: Array) -> Array:
	var result = []
	for section: Array in sections:
		if section.size() >= minRoomCells + 4: # We want some passageway between rooms/stairwells
			result.append(section)
	
	return result

# Generates a stairwell going up
func GenerateUpStairwell(layer: DungeonLayer, center) -> RoomBase:
	#var startX = center.x - (scale-1)/2
	#var startY = center.y - (scale-1)/2
	#GenerateSquareRoom(layer, startX, startY, scale)
	#layer.SetTile(center.x, center.y, Constants.DUNGEON_TILES.UP_STAIRS)
	var room = SquareStairwell.new(scale, center, Constants.DUNGEON_TILES.UP_STAIRS)
	layer.AddRoom(room)
	return room

# Generates a stairwell going down	
func GenerateDownStairwell(layer: DungeonLayer, center) -> RoomBase:
	#var startX = center.x - (scale-1)/2
	#var startY = center.y - (scale-1)/2
	#GenerateSquareRoom(layer, startX, startY, scale)
	#layer.SetTile(centere.x, center.y, Constants.DUNGEON_TILES.DOWN_STAIRS)
	var room = SquareStairwell.new(scale, center, Constants.DUNGEON_TILES.DOWN_STAIRS)
	layer.AddRoom(room)
	return room

# Generates a stairwell going both up and down
func GenerateDualStairwell(layer: DungeonLayer, center) -> RoomBase:
	#var startX = center.x - (scale-1)/2
	#var startY = center.y - (scale-1)/2
	#var result = GenerateSquareRoom(layer, startX, startY, scale)
	#layer.SetTile(center.x, center.y, Constants.DUNGEON_TILES.DUAL_STAIRS)
	var room = SquareStairwell.new(scale, center, Constants.DUNGEON_TILES.DUAL_STAIRS)
	layer.AddRoom(room)
	return room

# Generates a square room
#func GenerateSquareRoomFromCorner(layer: DungeonLayerrBase, xStart: int, yStart: int, width: int) -> RoomBase:
	#return GenerateRectangleRoom(layer, xStart, yStart, width, width)

# Generates a rectangle room
#func GenerateRectangleRoomFromCorner(layer: DungeonLayer, xStart: int, yStart: int, width: int, height: int) -> RoomBase:
	#pass
			

func GenerateSquareRoomFromCentre(layer: DungeonLayer, center: Vector2i, width: int, cellWidth: int) -> RoomBase:
		var room = SquareRoom.new(Constants.ROOM_TYPE.NORMAL, width, cellWidth, center)
		layer.AddRoom(room)
		return room

func GenerateRectangleRoomFromCentre(layer: DungeonLayer, center: Vector2i, width: int, height: int) -> RoomBase:
		var room = RectangularRoom.new(Constants.ROOM_TYPE.NORMAL, width, height, center)
		layer.AddRoom(room)
		return room
	

func UpdateMinRooms(value: float) -> void:
	minRooms = value

# Update the maximum number of rooms
func UpdateMaxRooms(value: float) -> void:
	maxRooms = value
	
func DecorateRoom(room: RoomBase, map: Map, cell: Vector2i):
	if decorator!= null:
		decorator.DecorateRoom(room, map, cell)
