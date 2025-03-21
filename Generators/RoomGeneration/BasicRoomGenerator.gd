extends RoomGeneratorBase

class_name BasicRoomGenerator

func GenerateRooms(map: Map, sections: Array):

	
	var roomsToAdd = rng.randi_range(minRooms, maxRooms)
	
	var sectionsWithSpace = super.GetSectionsLargeEnoughForARoom(sections)
	
	if sectionsWithSpace.size() == 0:
		return
	
	while roomsToAdd >0 and sectionsWithSpace.size() != 0:
		# Random section
		
		var selectedSection = sectionsWithSpace[rng.randi_range(0,sectionsWithSpace.size()-1)]
		
		var selectedSectionIndexInOverallSections = sections.find(selectedSection)
		
		var selectedCellIndex =rng.randi_range(2, selectedSection.size()-3)
		
		var selectedCell = selectedSection[selectedCellIndex]
		
		var layer = map.dungeon.getLayers()[selectedCell.z]
		
		var cellCenterPoint = UtilityMethods.GetCentralPointFromOverWorldVect(selectedCell, map.overworldToDungeonScale)
		
		var maxSize = GenerateSquareCenteredRoomSize(map.underground.getLayer(selectedCell.z), selectedSection, selectedCell, selectedCellIndex)
		#min(maxRoomCells, (selectedSection.size()-1) - selectedCellIndex)
		var size = rng.randi_range(minRoomCells, maxSize)
		
		var room =super.GenerateSquareRoomFromCentre(layer, cellCenterPoint, size * map.overworldToDungeonScale)
		
		room.AddDoors(selectedSection, selectedCellIndex, scale)
		
		sections =ReprocessSections(sections, selectedSectionIndexInOverallSections, room, selectedCellIndex)
		sectionsWithSpace = super.GetSectionsLargeEnoughForARoom(sections)
		roomsToAdd-=1
	
func GenerateSquareCenteredRoomSize(undergroundLayer: UndergroundLayer, section: Array, cell, cellIndex) -> int:
	
	# First, make sure that room size doesn't reach the star/end of section
	var maxSectionDistance = CalculateMaxSizeSquareFromSections(section, cell)
	
	# Next we check against the underground structure
	var maxStructureDistance = CalculateMaxSizeSquareFromUndergroundStructure(undergroundLayer, cell)
	
	
	
	var maxSize = min(maxSectionDistance, maxStructureDistance)
	
	var generatedSize = rng.randi_range(minRoomCells, maxSize)
	
	return generatedSize

func CalculateMaxSizeSquareFromUndergroundStructure(undergroundLayer: UndergroundLayer, cell) -> int:
	# We can limit how far we need to check to max room size
	# This max size will be limited to odd numbers
	
	if maxRoomCells == 1:
		return 1
	
	var checked = false
	# Distance checked from center
	var checkDistance = 0
	var maxStructureDistance = maxRoomCells;
	
	while not checked:
		checkDistance +=1
		
		# Top Left Corner of square to check
		var checkTLCornerX = cell.x - checkDistance
		var checkTLCornerY = cell.y - checkDistance
		
		# Bottom Right Corner of square to check
		var checkBRCornerX = cell.x + checkDistance
		var checkBRCornerY = cell.y + checkDistance
		
		# Width of square to check
		var checkSize = checkDistance *2 +1
		
		# Check the boundary of the checked square
		for i in checkSize:
			# Check from opposite corners
			if (undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkTLCornerX+ i, checkTLCornerY, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			|| undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkTLCornerX, checkTLCornerY+i, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			|| undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkBRCornerX -i, checkBRCornerY, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			||  undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkBRCornerX, checkBRCornerY - i, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN):
				return checkSize -2
				#maxStructureDistance = checkSize - 2
				checked = true
				break
			
		# Limit checks to the max room size
		if checkSize == self.maxRoomCells:
			return checkSize
			checked = true
			break
	return maxStructureDistance

func CalculateMaxSizeSquareFromSections(section, cell):
	# We assume that the sections are continuos, the cell is part of the section
	# and that the if the section curves on itself the structure size max will
	# handle this
	
	# []-x--[]
	# We want at least one empty passageway cell between rooms
	#
	# This is a square room so take the minimum of the x and y distances
	var startXDistance = abs(section[1].x - cell.x)
	var startYDistance = abs(section[1].y - cell.y)
	var startTotalDistance = 2*max(startXDistance, startYDistance)-1
	
	
	var endXDistance = abs(section[-2].x - cell.x)
	var endYDistance = abs(section[-2].y - cell.y)
	var endTotalDistance = 2*max(endXDistance, endYDistance)-1
	
	return min(startTotalDistance, endTotalDistance)

func ReprocessSections(sections: Array, changedSectionIndex: int, addedRoom: RoomBase, roomSectionIndex: int) -> Array:
	
	var result = []
	
	for i in changedSectionIndex:
		result.append(sections[i])
		
	result.append_array(addedRoom.SeperateSection(sections[changedSectionIndex], roomSectionIndex))
	
	
	
	for i in range(changedSectionIndex, sections.size()):
		result.append(sections[i])
		
	return result

func AddDoorsToSquareRoom(section: Array, room: RoomBase, index: int):
	room.AddDoors(section, index, scale)
	
	
