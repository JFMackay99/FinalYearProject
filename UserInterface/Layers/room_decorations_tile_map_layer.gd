extends TileMapLayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

func UpdateViewer(map: Map, heightLevel):
	clear()
	var dungeonLayer = map.dungeon.dungeonLayers[heightLevel] as DungeonLayer
	
	for room : RoomBase in dungeonLayer.rooms:
		for decoration in room.decorations:
			set_cell(decoration[0],1,Vector2i(decoration[1],0))
			
	
