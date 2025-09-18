extends BasicUndergroundConstructor

class_name OverworldBasedUndergroundConstructor


func MarkAllLayerHeights(overworld : OverworldMap, layers : Array[LayerBase]):
	
	for i in layers.size():
		layers[i] = UndergroundLayer.new(i, Constants.OVERWORLD_MAX_X * scale, Constants.OVERWORLD_MAX_Y * scale)
	
	var tile = Constants.DUNGEON_TILES.FORBIDDEN
	for x in overworld.heights.size():
		for y in overworld.heights[x].size():
			var height = overworld.GetHeightAtCellCoordinate(x,y)
			for z in range(height+1,layers.size()):
				var layer = layers[z]
				var points = UtilityMethods.GetDungeonAreaFromOverworldCell(Vector2i(x,y), scale)
				for point in points:
					layer.SetTile(point.x,point.y, tile)
				
