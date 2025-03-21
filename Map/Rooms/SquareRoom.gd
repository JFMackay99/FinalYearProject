extends RoomBase

class_name SquareRoom

var width: int
var topLeft: Vector2i
var center: Vector2i

func _init(type: Constants.ROOM_TYPE, 
	width: int,
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

func SeperateSection(section: Array, index: int):
	var start = []
	var end = []
	
	# Remove from start section
	
	var checked = false
	var cursor = index
	
	while not checked:
		cursor-= 1
		var point = Vector2i(section[cursor].x, section[cursor].y)
		checked = not self.IsPointInRoom(point)
	
	for i in range(0, cursor +1):
		start.append(section[i])
		
	checked = false
	cursor = index
	
	while not checked:
		cursor+= 1
		var point = Vector2i(section[cursor].x, section[cursor].y)
		checked = not self.IsPointInRoom(point)
	
	for i in range(cursor, section.size()):
		end.append(section[i])
	
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
			doorVect = Vector2i(boundaryCellCenter.x+scale/2, boundaryCellCenter.y)
		Constants.DIRECTION.WEST:
			doorVect = Vector2i(boundaryCellCenter.x-scale/2, boundaryCellCenter.y)
	
	return doorVect

func GetIndexOfPathSectionsPassingBoundary(section: Array, centerIndex: int) -> Vector2i:
	
	var cursor = 0
	var checked = false
	var startBoundaryIndex = -1
	var endBoundaryIndex = -1
	
	# The room takes up full cells
	
	# From center to start of section
	while(not checked):
		var checkedIndex = centerIndex - cursor
		var checkedCell = section[checkedIndex]
		
		var xDistance = abs(center.x - checkedCell.x)
		var yDistance = abs(center.y - checkedCell.y)
		
		var maxDistance = max(xDistance, yDistance)
		
		if maxDistance > width/2:
			checked = true
		else:
			startBoundaryIndex = checkedIndex
			cursor+=1
		
	# From center to end of section
	checked = false
	cursor = 0
	while(not checked):
		var checkedIndex = centerIndex + cursor
		var checkedCell = section[checkedIndex]
		
		var xDistance = abs(center.x - checkedCell.x)
		var yDistance = abs(center.y - checkedCell.y)
		
		var maxDistance = max(xDistance, yDistance)
		
		if maxDistance > width/2:
			checked = true
		else:
			endBoundaryIndex = checkedIndex
			cursor +=1
	
	
	return Vector2i(startBoundaryIndex, endBoundaryIndex)
