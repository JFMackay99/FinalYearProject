extends TileMapLayer

var availableLayers: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

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


func updateDungeonLayer(layer: LayerBase):
	clear()
	
	var maxX = layer.mapMaxWidth #layer.maxX+2#
	var maxY = layer.mapMaxHeight #layer.maxY+2#
	for i in maxX:
		for j in maxY:
			var tile = layer.GetTile(i,j)
			var coordVector =Vector2i(i, j)
			set_cell(coordVector, 0, Vector2i(tile, 0))
	
func UpdateViewer(map: Map, heightLevel):
	clear()
	var foo = map.underground.layers
	var undergroundLayer = map.underground.layers[heightLevel] as UndergroundLayer
	var dungeonLayer = map.dungeon.dungeonLayers[heightLevel] as DungeonLayer
	
	for x in undergroundLayer.mapMaxWidth:
		for y in undergroundLayer.mapMaxHeight:
			var tile = undergroundLayer.GetTile(x,y)
			var coordVector = Vector2i(x,y)
			set_cell(coordVector, 0, Vector2i(tile, 0))
			
	for tileCoords in dungeonLayer.tiles:
			var coordVector = Vector2i(tileCoords.x,tileCoords.y)
			var tile = dungeonLayer.GetTile(tileCoords.x, tileCoords.y)
			set_cell(coordVector, 0, Vector2i(tile, 0))
		
			
	
