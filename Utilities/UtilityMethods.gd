extends Node



# For a given point in a dungeon layer, gets the central point of the corresponding overworld coordinate
func GetCentralPointFromDungeonPoint(x,y, scale):
	var owVect = GetOverworldCellCoordsFromDungeonPoint(x,y, scale)
	return GetCentralPointFromOverWorldVect(owVect, scale)

# Gets an area of the dungeon layer that corresponds to the given overworld coordinates
func GetDungeonAreaFromOverworldCell(owCoords, scale):
	var area = Array()
	for i in scale:
		for j in scale:
			area.append(Vector2i(owCoords.x*scale +i, owCoords.y*scale + j))
	return area

# Gets the central point of an area of the dungeon layers that correspond to the given overworld
# coordinates
func GetCentralPointFromOverWorldVect(cellVect, scale):
	return GetCentralPointFromOverWorldCoords(cellVect.x, cellVect.y, scale)

# Gets the central point of an area of the dungeon layers that correspond to the given overworld
# coordinates
func GetCentralPointFromOverWorldCoords(cellX, cellY, scale):
	var x = cellX * scale + (scale/2)
	var y = cellY * scale + (scale/2)
	return Vector2i(x, y)

func GetTopLeftPointFromCell(cell: Vector2i, scale):
	var x = cell.x * scale 
	var y = cell.y * scale 
	return Vector2i(x,y)
	
func GetTopLeftPointFrom3dCell(cell: Vector3, scale):
	return GetTopLeftPointFromCell(Vector2i(cell.x, cell.y), scale)


# Gets the overworld coordinates corresponding to a given point in a dungeon layer
func GetOverworldCellCoordsFromDungeonPoint(x,y, scale):
	return Vector2i(x/scale, y/scale)

func CalculateDirectionFromOrthogonalCoords(from, to):
	if from.x != to.x:
		if from.x < to.x:
			return Constants.DIRECTION.WEST
		else:
			return Constants.DIRECTION.EAST
	if from.y != to.y:
		if from.y < to.y:
			return Constants.DIRECTION.NORTH
		else:
			return Constants.DIRECTION.SOUTH
	if from.z != to.z:
		if from.z < to.y:
			return Constants.DIRECTION.UP
		else:
			return Constants.DIRECTION.DOWN
	
	return Constants.DIRECTION.SAME
