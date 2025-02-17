extends RoomGeneratorBase

class_name BasicRoomGenerator

func GenerateRooms(map: Map, sections: Array):
	
	var aaacheckMinRoom = minRooms
	var aabcheckMaxRooms = maxRooms
	var aafcheckMinSize = minRoomCells
	var aaccheckMaxSize = maxRoomCells
	
	
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
		
		var cellCenter = UtilityMethods.GetCentralPointFromOverWorldVect(selectedCell, map.overworldToDungeonScale)
		
		var maxSize = GenerateSquareCenteredRoomSize(map.underground.getLayer(selectedCell.z), selectedSection, selectedCell, selectedCellIndex)
		#min(maxRoomCells, (selectedSection.size()-1) - selectedCellIndex)
		var size = rng.randi_range(minRoomCells, maxSize)
		
		var room =super.GenerateSquareRoomFromCentre(layer, cellCenter, size * map.overworldToDungeonScale)
		
		sections =ReprocessSections(sections, selectedSectionIndexInOverallSections, room, selectedCellIndex)
		sectionsWithSpace = super.GetSectionsLargeEnoughForARoom(sections)
		roomsToAdd-=1
	
func GenerateSquareCenteredRoomSize(undergroundLayer: UndergroundLayer, section: Array, cell, cellIndex) -> int:
	
	# First, make sure that room size doesn't reach the star/end of section
	
	# []-x--[]
	# We want at least one empty passageway cell between rooms
	#
	# This is a square room so take the minimum of the x and y distances
	var startXDistance = abs(section[1].x - cell.x)
	var startYDistance = abs(section[1].y - cell.y)
	var startTotalDistance = min(startXDistance, startYDistance)
	
	
	var endXDistance = abs(section[-2].x - cell.x)
	var endYDistance = abs(section[-2].y - cell.y)
	var endTotalDistance = min(endXDistance, endYDistance)
	
	var maxSectionDistance = min(startTotalDistance, endTotalDistance)
	
	
	
	
	# Next we check against the underground structure
	# We can limit how far we need to check to max room size
	# This max size will be limited to odd numbers
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
		
		for i in checkSize:
			# Check from top left corner
			if (undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkTLCornerX+ i, checkTLCornerY, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			|| undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkTLCornerX, checkTLCornerY+i, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			|| undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkBRCornerX -i, checkBRCornerY, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN 
			||  undergroundLayer.GetTileFromVect(UtilityMethods.GetCentralPointFromOverWorldCoords(checkBRCornerX, checkBRCornerY - i, self.scale)) == Constants.DUNGEON_TILES.FORBIDDEN):
				maxStructureDistance = checkSize - 2
				checked = true
				break
			
			# Limit checks to the max room size
			if checkSize == maxRoomCells:
				checked = true
				break
	
	
	
	var maxSize = min(maxSectionDistance, maxStructureDistance)
	
	var generatedSize = rng.randi_range(minRoomCells, maxSize)
	
	return generatedSize

func ReprocessSections(sections: Array, changedSectionIndex: int, addedRoom: RoomBase, roomSectionIndex: int) -> Array:
	
	var result = []
	
	for i in changedSectionIndex:
		result.append(sections[i])
		
	result.append_array(addedRoom.SeperateSection(sections[changedSectionIndex], roomSectionIndex))
	
	
	
	for i in range(changedSectionIndex, sections.size()):
		result.append(sections[i])
		
	return result
