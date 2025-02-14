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
		var maxSize = min(maxRoomCells, (selectedSection.size()-1) - selectedCellIndex)
		var size = rng.randi_range(minRoomCells, maxSize)
		
		var room =super.GenerateSquareRoomFromCentre(layer, cellCenter, size * map.overworldToDungeonScale)

		roomsToAdd-=1
		
		return
	
	pass
