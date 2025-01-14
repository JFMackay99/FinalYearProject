extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Regenerate(map):
	for i in map.size():
		for j in map[i].size():
			var tileIndexVector = Vector2i(0, SelectTileIndex(map[i][j]))
			var coordVector = Vector2i(i,j)
			set_cell(coordVector, 2, tileIndexVector)
	
func SelectTileIndex(height: float):
	#TODO: Tile set is upside down, when we need to change it just use height
	var index = floor(height)
	return index
	
