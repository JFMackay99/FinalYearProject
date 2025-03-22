extends RoomBase

class_name SquareRoom

var width: int
var cellWidth: int
var topLeft: Vector2i
var center: Vector2i


func _init(type: Constants.ROOM_TYPE, 
	width: int,
	cellWidth: int,
	center: Vector2i,
	floorTiles =Constants.DUNGEON_TILES.ROOM,
	boundaryTiles =Constants.DUNGEON_TILES.WALL
	):
	
	super(
		type, 
		Constants.ROOM_SHAPE.RECTANGULAR, 
		floorTiles, 
		boundaryTiles)
	self.width = width
	self.cellWidth = cellWidth
	var startX = center.x - (width-1)/2
	var startY = center.y - (width-1)/2
	self.topLeft = Vector2i(startX, startY)
	self.center = center
	
	# Floor
	for x in width:
		for y in width:
			var point = Vector2i(startX + x, startY + y)
			self.floor.append(point)
			if x == 0 || x == width-1 || y == 0 || y == width-1:
				self.boundary.append(point)


# Seperate the section into two pieces that do not pass through this room.
func SeperateSection(section: Array, index: int) -> Array:
	var start = []
	var end = []
	
	# Get indices of section
	var boundaryIndices = GetIndexOfPathSectionsPassingBoundary(section,index)
	var endOfStartSectionIndex = boundaryIndices.x
	var startOfEndSectionIndex = boundaryIndices.y+1
	
	# Get start and end of section based on these indices
	start = section.slice(0, endOfStartSectionIndex)
	end = section.slice(startOfEndSectionIndex)
	
	return [start, end]
	

func AddDoors(section: Array, centerIndex: int, scale: int):
	#
	#
	#
	#					S	r	r	r	r
	#					r	r	r	r	r
	#	x	x	x	x	D	r	C	r	r
	#					r	r	r	r	r
	#					r	r	D	r	r
	#							x
	#							x
	
	# Recall the section is in overworld cells and the room is in dungeon 
	
	# Assume that there are no points where the path returns to the room
	
	
	var boundarySectionIndices = GetIndexOfPathSectionsPassingBoundary(section, centerIndex)
	var startBoundaryIndex = boundarySectionIndices.x
	var endBoundaryIndex = boundarySectionIndices.y
	
	var startBoundaryCell = section[startBoundaryIndex]
	var endBoundaryCell = section[endBoundaryIndex]
	
	var startOutOfBoundaryCell = section[startBoundaryIndex-1]
	var endOutOfBoundaryCell = section[endBoundaryIndex+1]
	
	var startDoor = CalculateDoorPosition(startBoundaryCell, startOutOfBoundaryCell, scale)
	var endDoor = CalculateDoorPosition(endBoundaryCell, endOutOfBoundaryCell, scale)
	
	doors.append(startDoor)
	doors.append(endDoor)
	
	
	

func CalculateDoorPosition(boundaryCell, outOfBoundaryCell, scale) -> Vector2i:
	var direction = UtilityMethods.CalculateDirectionFromOrthogonalCoords(boundaryCell, outOfBoundaryCell)
	
	var boundaryCellCenter = UtilityMethods.GetCentralPointFromOverWorldVect(boundaryCell, scale)
	
	var doorVect
	match direction:
		Constants.DIRECTION.NORTH:
			doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y+scale/2)
		Constants.DIRECTION.SOUTH:
			doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y-scale/2)
		Constants.DIRECTION.EAST:
			doorVect = Vector2i(boundaryCellCenter.x-scale/2, boundaryCellCenter.y)
		Constants.DIRECTION.WEST:
			doorVect = Vector2i(boundaryCellCenter.x+scale/2, boundaryCellCenter.y)
	
	return doorVect

func GetIndexOfPathSectionsPassingBoundary(section: Array, centerIndex: int) -> Vector2i:
	
	var cursor = 0
	var centerCell = section[centerIndex]
	var checked = false
	var startBoundaryIndex = -1
	var endBoundaryIndex = -1
	
	# The room takes up full cells
	
	# From center to start of section
	if centerIndex !=0:
		while(not checked):
			
			var checkedIndex = centerIndex - cursor
			var checkedCell = section[checkedIndex]
			
			var xDistance = abs(centerCell.x - checkedCell.x)
			var yDistance = abs(centerCell.y - checkedCell.y)
			
			var maxDistance = max(xDistance, yDistance)
			
			if maxDistance > cellWidth/2:
				checked = true
			else:
				startBoundaryIndex = checkedIndex
				cursor+=1
			
	# From center to end of section
	checked = false
	cursor = 0
	if centerIndex != section.size()-1:
		while(not checked):
			var checkedIndex = centerIndex + cursor
			var checkedCell = section[checkedIndex]
			
			var xDistance = abs(centerCell.x - checkedCell.x)
			var yDistance = abs(centerCell.y - checkedCell.y)
			
			var maxDistance = max(xDistance, yDistance)
			
			if maxDistance > cellWidth/2:
				checked = true
			else:
				endBoundaryIndex = checkedIndex
				cursor +=1
		
	
	return Vector2i(startBoundaryIndex, endBoundaryIndex)
