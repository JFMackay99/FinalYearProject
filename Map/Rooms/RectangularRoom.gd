extends RoomBase

class_name RectangularRoom

var width: int
var height: int
var topLeft: Vector2i

func _init(type: Constants.ROOM_TYPE, 
	width: int,
	height: int,
	center: Vector2i,
	floorTiles =Constants.DUNGEON_TILES.ROOM,
	boundaryTiles =Constants.DUNGEON_TILES.WALL
	):
	
	super(
		Constants.ROOM_TYPE.NORMAL, 
		Constants.ROOM_SHAPE.RECTANGULAR, 
		floorTiles, 
		boundaryTiles)
	self.width = width
	self.height = height
	var startX = center.x - (width-1)/2
	var startY = center.y - (height-1)/2
	self.topLeft = Vector2i(startX, startY)
	
	# Floor
	for x in width:
		for y in height:
			var point = Vector2i(startX + x, startY + y)
			self.floor.append(point)
			if x == 0 || x == width-1 || y == 0 || y == width-1:
				self.boundary.append(point)
