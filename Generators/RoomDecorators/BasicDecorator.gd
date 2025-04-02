extends DecoratorBase

class_name BasicDecorator

static var decorationCountMeanNormal =0.5
static var decorationCountDeviation = 0.1

var decorationsPerBiome = {}

var defaultDecorations = [Constants.ROOM_DECORATION.TORCH, Constants.ROOM_DECORATION.DESK, Constants.ROOM_DECORATION.CHAIR, Constants.ROOM_DECORATION.CHEST]

func DecorateRoom(room: RoomBase, map: Map, cell):
	
	var cellBiome = map.overworld.GetBiomeAtCellCoordinate(cell.x, cell.y)
	
	var decorationOptions: Array
	
	if decorationsPerBiome.has(cellBiome):
		decorationOptions = decorationsPerBiome[cellBiome]
	else:
		decorationOptions = defaultDecorations
	
	var freeSpaceCopy = room.floor.duplicate()
	
	var numberOfDecorations = CalculateNumberOfDecorations(freeSpaceCopy)
	
	for i in numberOfDecorations:
		var pointIndex = rng.randi_range(0, freeSpaceCopy.size())
		var point = freeSpaceCopy.pop_at(pointIndex)
		
		var decoration = decorationOptions.pick_random()
		
		room.AddDecoration(point, decoration)

func CalculateNumberOfDecorations(freeSpace: Array) -> int:
	var max = freeSpace.size()
	
	var normalised = rng.randfn(decorationCountMeanNormal, decorationCountDeviation)
	
	var clamped = clampf(normalised, 0,1)
	
	# Value between 0 and maximum value
	var result = clamped*max as int
	
	return result
	
