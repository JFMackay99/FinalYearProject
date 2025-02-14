extends RoomGeneratorBase

class_name BasicRoomGenerator

func GenerateRooms(map: Map, sections: Array):
	
	var foo = minRooms
	var bar = maxRooms
	
	
	var roomsToAdd = rng.randi_range(minRooms, maxRooms)
	
	var sectionsWithSpace = super.GetSectionsLargeEnoughForARoom(sections)
	
	if sectionsWithSpace.size() == 0:
		return
	
	while roomsToAdd >0 and sectionsWithSpace.size() != 0:
		# Random section
		
		var selectedSection = sectionsWithSpace[rng.randi_range(0,sectionsWithSpace.size()-1)]
		
		var selectedCellIndex =rng.randi_range(2, selectedSection.size()-3)
		
		var selectedCell = selectedSection[selectedCellIndex]
		
		var layer = map.dungeon.getLayers()[selectedCell.z]
		
		var cellCenter = UtilityMethods.GetCentralPointFromOverWorldVect(selectedCell, map.overworldToDungeonScale)
		
		# TODO Make sure the room doesn't go outside. 
		var maxSize = GenerateSquareCenteredRoomSize(map.underground.getLayer(selectedCell.z), selectedSection, selectedCell, selectedCellIndex)
		#min(maxRoomCells, (selectedSection.size()-1) - selectedCellIndex)
		var size = rng.randi_range(minRoomCells, maxSize)
		
		var room =super.GenerateSquareRoomFromCentre(layer, cellCenter, size * map.overworldToDungeonScale)

		roomsToAdd-=1
		# TODO Re-process sections to seperate by rooms
		return
	
func GenerateSquareCenteredRoomSize(undergroundLayer: UndergroundLayer, section: Array, cell, cellIndex) -> int:
	
	var maxSizeFromSection = (section.size()-1) - cellIndex
	
	# If there isn't a used tile that's within the max size, use maxRoomCells
	var MaxSizeFromUndergroundStructure = maxRoomCells
	var finished = false
	for distance in ceil((maxRoomCells-1)/2)+1:
		if finished:
			break
		for x in distance+1:
			if finished:
				break
			for y in distance+1:
				if finished:
					break
				var neighbourCell = undergroundLayer.GetTile(cell.x + x,cell.y + y);
				if (neighbourCell != Constants.DUNGEON_TILES.ROCK):
					MaxSizeFromUndergroundStructure = 2*distance-1;
					finished = true
				
	
	var maxSize = min(maxSizeFromSection, MaxSizeFromUndergroundStructure)
	var generatedSize = rng.randi_range(minRoomCells, maxSize)
	
	return generatedSize
