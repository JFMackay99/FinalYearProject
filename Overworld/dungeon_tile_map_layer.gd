extends TileMapLayer

var availableLayers: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func updateLayers(dungeonLayers: Array):
	availableLayers.clear()
	for layer in dungeonLayers:
		updateDungeonLayer(layer)
		var tileMapData = get_tile_map_data_as_array
		availableLayers.append(tileMapData)

func selectLayer(z: int):
	clear()
	var newLayer =availableLayers[z]
	set_tile_map_data_from_array(newLayer)


func updateDungeonLayer(layer: DungeonLayer):
	clear()
	
	var minX= 0#layer.minX-1#
	var minY= 0#layer.minY-1#
	var maxX = layer.map.size() #layer.maxX+2#
	var maxY = layer.map[0].size() #layer.maxY+2#
	for i in range(minX, maxX):
		for j in range(minY, maxY):
			var tile = layer.map[i][j]
			var coordVector =Vector2i(i-minX, j - minY)
			set_cell(coordVector, 0, Vector2i(tile, 0))
	
			
