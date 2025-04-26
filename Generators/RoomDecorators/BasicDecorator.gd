extends DecoratorBase

class_name BasicDecorator

var decorationsPerBiome = {}

var defaultDecorations = [Constants.ROOM_DECORATION.TORCH,
	Constants.ROOM_DECORATION.DESK, 
	Constants.ROOM_DECORATION.CHAIR, 
	Constants.ROOM_DECORATION.CHEST,
	Constants.ROOM_DECORATION.GOLD,
	]

func DecorateRoom(room: RoomBase, map: Map, centerCell):
	
	var cellBiome = map.overworld.GetBiomeAtCellCoordinate(centerCell.x, centerCell.y)
	
	var decorationOptions: Array
	
	decorationOptions = SelectDecorationOptionsFromBiome(cellBiome)
	
	var freeSpaceCopy = room.floor.duplicate()
	var freeSpaceSize = freeSpaceCopy.size()
	
	var numberOfDecorations = CalculateNumberOfDecorations(freeSpaceCopy)
	
	for i in numberOfDecorations:
		var pointIndex = rng.randi_range(0, freeSpaceCopy.size()-1)
		var point = freeSpaceCopy.pop_at(pointIndex)
		
		var decoration = decorationOptions.pick_random()
		
		if point == null:
			print("Error adding decoration " + str(i) + "to room. There is room for " + str(freeSpaceSize) + " but " + str(numberOfDecorations) + " was calculated to be added")
			break
			
		room.AddDecoration(point, decoration)

func CalculateNumberOfDecorations(freeSpace: Array) -> int:
	var max = freeSpace.size()
	
	var normalised = rng.randfn(decorationCountMeanNormal, decorationCountDeviation)
	
	var clamped = clampf(normalised, 0,1)
	
	# Value between 0 and maximum value
	var result = clamped*max as int
	
	return result
	
func SelectDecorationOptionsFromBiome(cellBiome: Constants.BIOMES):
	var decorationOptions
	if decorationsPerBiome.has(cellBiome):
		decorationOptions = decorationsPerBiome[cellBiome]
	else:
		decorationOptions = defaultDecorations
		
	return decorationOptions
