extends TileMapLayer

var tileIndex ={
	Constants.ROOM_DECORATION.TORCH: Vector2i(0,0),
	Constants.ROOM_DECORATION.DESK: Vector2i(1,0),
	Constants.ROOM_DECORATION.CHAIR: Vector2i(2,0),
	Constants.ROOM_DECORATION.CHEST: Vector2i(3,0),
	Constants.ROOM_DECORATION.ROCK: Vector2i(4,0),
	Constants.ROOM_DECORATION.VINES: Vector2i(5,0),
	Constants.ROOM_DECORATION.PUDDLE: Vector2i(6,0),
	Constants.ROOM_DECORATION.LEAVES: Vector2i(7,0),
	Constants.ROOM_DECORATION.GOLD: Vector2i(0,1),
	Constants.ROOM_DECORATION.GEM: Vector2i(1,0),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func UpdateViewer(map: Map, heightLevel):
	clear()
	var dungeonLayer = map.dungeon.dungeonLayers[heightLevel] as DungeonLayer
	
	for room : RoomBase in dungeonLayer.rooms:
		for decoration in room.decorations:
			var location = decoration[0]
			var decorationType = decoration[1]
			var tile = tileIndex[decorationType]
			
			set_cell(location,1,tile)
			
	
