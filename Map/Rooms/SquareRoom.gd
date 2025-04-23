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
	
	var startX
	var startY
	
	var scale = width/cellWidth
	
	#Odd sized rooms is simple enough
	if cellWidth %2 !=0:
		startX = center.x - (width-1)/2
		startY = center.y - (width-1)/2
		self.topLeft = Vector2i(startX, startY)
	else:
		
		var delta = ((width-2)/2) - ((scale)/2)
		
		startX = center.x - delta
		startY = center.y - delta
		self.topLeft = Vector2i(startX, startY)
	
	self.center = center
	
	# Floor
	for x in width:
		for y in width:
			var point = Vector2i(startX + x, startY + y)
			if x == 0 || x == width-1 || y == 0 || y == width-1:
				self.boundary.append(point)
			else:
				self.floor.append(point)
	
	self.floorSizePoints = self.floor.size()
	


# Seperate the section into two pieces that do not pass through this room.
# Returns an array containing [start,end] sections
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
	
	if startBoundaryIndex != -1:
		var startOutOfBoundaryCell = section[startBoundaryIndex-1]
		var startBoundaryCell = section[startBoundaryIndex]
		var startDoor = CalculateDoorPosition(startBoundaryCell, startOutOfBoundaryCell, scale)
		doors.append(startDoor)
	if endBoundaryIndex != -1:
		var endBoundaryCell = section[endBoundaryIndex]
		var endOutOfBoundaryCell = section[endBoundaryIndex+1]
		var endDoor = CalculateDoorPosition(endBoundaryCell, endOutOfBoundaryCell, scale)
		doors.append(endDoor)
	
	

func CalculateDoorPosition(boundaryCell, outOfBoundaryCell, scale) -> Vector2i:
	var direction = UtilityMethods.CalculateDirectionFromOrthogonalCoords(boundaryCell, outOfBoundaryCell)
	
	var boundaryCellCenter = UtilityMethods.GetCentralPointFromOverWorldVect(boundaryCell, scale)
	
	var doorVect
	if scale%2==1:
		match direction:
			Constants.DIRECTION.NORTH:
				doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y+scale/2)
			Constants.DIRECTION.SOUTH:
				doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y-scale/2)
			Constants.DIRECTION.EAST:
				doorVect = Vector2i(boundaryCellCenter.x-scale/2, boundaryCellCenter.y)
			Constants.DIRECTION.WEST:
				doorVect = Vector2i(boundaryCellCenter.x+scale/2, boundaryCellCenter.y)
	else:
		print(direction)
		match direction:
			Constants.DIRECTION.NORTH:
				doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y+scale/2)
			Constants.DIRECTION.SOUTH:
				doorVect = Vector2i(boundaryCellCenter.x, boundaryCellCenter.y+1-scale/2)
			Constants.DIRECTION.EAST:
				doorVect = Vector2i(boundaryCellCenter.x+1-scale/2, boundaryCellCenter.y)
			Constants.DIRECTION.WEST:
				doorVect = Vector2i(boundaryCellCenter.x+scale/2, boundaryCellCenter.y)
		
	return doorVect

# Gets the index of the section contents that represent the cells in the section
# that pass the boundary of the room
func GetIndexOfPathSectionsPassingBoundary(section: Array, centerIndex: int) -> Vector2i:
	
	var cursor = 0
	var centerCell = section[centerIndex]
	var checked = false
	var startBoundaryIndex = -1
	var endBoundaryIndex = -1
	
	
	# Odd sized rooms are simpler, just check equally in each direction
	if cellWidth %2 == 1:
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
		
	# Even sized rooms
	else:
		# Rooms are one bigger to the east and south
		var maxEastDistance = -((cellWidth)/2)
		var maxSouthDistance = -((cellWidth)/2)
		var maxNorthDistance = ((cellWidth-1)/2)
		var maxWestDistance = ((cellWidth-1)/2)
		# (0,0) is top left
		
		# To Start
		if centerIndex !=0:
			while(not checked):
				
				var checkedIndex = centerIndex - cursor
				var checkedCell = section[checkedIndex]
				
				var xDistance = centerCell.x - checkedCell.x
				var yDistance = centerCell.y - checkedCell.y
				
				# positive yDistance is north
				
				if (
				xDistance > maxWestDistance or
				xDistance < maxEastDistance or 
				yDistance > maxNorthDistance or 
				yDistance < maxSouthDistance	
				):
					checked = true
				else:
					startBoundaryIndex = checkedIndex
					cursor+=1
		
		checked = false
		cursor = 0
		# To end# To Start
		if centerIndex !=0:
			while(not checked):
				
				var checkedIndex = centerIndex + cursor
				var checkedCell = section[checkedIndex]
				
				var xDistance = centerCell.x - checkedCell.x
				var yDistance = centerCell.y - checkedCell.y
				
				# positive xDistance is west, positive yDistance is north?
				
				if (
				xDistance > maxWestDistance or
				xDistance < maxEastDistance or 
				yDistance > maxNorthDistance or 
				yDistance < maxSouthDistance	
				):
					checked = true
				else:
					endBoundaryIndex = checkedIndex
					cursor+=1
		
		
		return Vector2i(startBoundaryIndex,endBoundaryIndex)

func CalculateAvailableSpace():
	return self.floor.size()
