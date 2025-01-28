extends TileMapLayer
var showHeights = true
var showBiomes = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Regenerate(overworld: OverworldMap):
	for i in Constants.OVERWORLD_MAX_X:
		for j in Constants.OVERWORLD_MAX_Y:
			var heightTileIndex = SelectHeightTileIndex(overworld.GetHeightAtCellCoordinate(i,j))
			var biomeTileIndex = SelectBiomeTileIndex(overworld.GetBiomeAtCellCoordinate(i,j))
			
			var tileIndexVector = Vector2i(biomeTileIndex, heightTileIndex)
			var coordVector = Vector2i(i,j)
			set_cell(coordVector, 0, tileIndexVector)
	
func SelectHeightTileIndex(height: float):
	var index = floor(height)
	return index if showHeights else 0
	
func SelectBiomeTileIndex(biome: int):
	return biome if showBiomes else 0
	
func ToggleViewHeights(toggled_on: bool, overworld: OverworldMap) -> void:
	showHeights = toggled_on
	Regenerate(overworld)

func ToggleViewBiomes(toggled_on: bool, overworld: OverworldMap) -> void:
	showBiomes = toggled_on
	Regenerate(overworld)
