extends Node2D

@export var numberOfDungeons:int = 1

# Available views to display to the user
var views : Array[Control]
var ActiveView: Control

# The overall Map
var map: Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Initialise views
	ActiveView = $MapViewContainer/MapSubViewport/OverworldViewer
	views = [$MapViewContainer/MapSubViewport/OverworldViewer, $MapViewContainer/MapSubViewport/DungeonViewer]
	for c: Control in views:
		c.hide()
	ActiveView.set_visible(true)
	
	# Initialise view control
	$ViewControls/ViewControlsContainer/Layer/LayerSelect.clear()
	$ViewControls/ViewControlsContainer/Layer/LayerSelect.add_item("Overworld Layer", 0)
	
	for z in Constants.MAX_HEIGHT_LEVELS:
		$ViewControls/ViewControlsContainer/Layer/LayerSelect.add_item("Dungeon Layer "+ str(z), z+1)
	GenerateMap()
	
# Update labels showing information about the generated overworld
func UpdateLabels():
	# For now we only need the coordinates of two dungeon entrances
	var entrance = map.entrances[0]
	$ViewControls/ViewControlsContainer/Entrances/E1/Coords/E1Coords.text = "(" + str(entrance.x) + "," + str(entrance.y) + ")"
	$ViewControls/ViewControlsContainer/Entrances/E1/Height/E1HeightValue.text = str(entrance.z)
	$ViewControls/ViewControlsContainer/Entrances/E1/Biome/E1BiomeValue.text = Constants.BIOMES.keys()[map.overworld.GetBiomeAtCellCoordinate(entrance.x, entrance.y)]
	
	entrance = map.entrances[1]
	$ViewControls/ViewControlsContainer/Entrances/E2/Coords/E2Coords.text = "(" + str(entrance.x) + "," + str(entrance.y) + ")"
	$ViewControls/ViewControlsContainer/Entrances/E2/Height/E2HeightValue.text = str(entrance.z)
	$ViewControls/ViewControlsContainer/Entrances/E2/Biome/E2BiomeValue.text = Constants.BIOMES.keys()[map.overworld.GetBiomeAtCellCoordinate(entrance.x, entrance.y)]
	
	
	
# Generate the full overworld. This is also called when the "pressed" signal is emmitted when the 
# regenerate overworld button is pressed.
func GenerateMap() -> void:
	var startMapGeneration = Time.get_ticks_msec()
	map = $GenerationManager.Generate()
	var endMapGeneration = Time.get_ticks_msec()
	var mapGenerationTime = endMapGeneration - startMapGeneration
	print("Overall Map Generation Time: " + str(mapGenerationTime)+ "ms")
	var startViewerUpdate = Time.get_ticks_msec()
	
	_UpdateViewers()
	var endViewerUpdate = Time.get_ticks_msec()
	var viewerUpdateTime = endViewerUpdate - startViewerUpdate
	print("Viewer Update Time: " + str(viewerUpdateTime)+ "ms")

func RegenerateDungeon() -> void:
	map = $GenerationManager.RegenerateDungeon()
	_UpdateViewers()

func _UpdateViewers():
	$MapViewContainer/MapSubViewport/OverworldViewer/OverworldTileMapLayer.Regenerate(map.overworld)
	$MapViewContainer/MapSubViewport/OverworldViewer/DungeonEntrances.AddDungeonEntrances(map.entrances)
	ChangeView($ViewControls/ViewControlsContainer/Layer/LayerSelect.get_selected_id())
	UpdateLabels()

# Change the view shown to the user. This is also called when the "itemSelect" signal is emmited
# when the layer view dropdown has its value changed
func ChangeView(value):
	ActiveView.hide()
	if value == 0:
		ActiveView = views[0]
		ActiveView.set_visible(true)
		return
	ActiveView = views[1]
	var dungeonLayer =map.dungeon.dungeonLayers[value-1]
	#$MapViewContainer/MapSubViewport/DungeonViewer/DungeonTileMapLayer.updateDungeonLayer(dungeonLayer)
	
	$MapViewContainer/MapSubViewport/DungeonViewer/DungeonTileMapLayer.UpdateViewer(map, value-1)
	ActiveView .set_visible(true)


func ToggleViewHeights(toggled_on: bool) -> void:
	$MapViewContainer/MapSubViewport/OverworldViewer/OverworldTileMapLayer.ToggleViewHeights(toggled_on,  map.overworld)
	
func ToggleViewBiomes(toggled_on: bool) -> void:
	$MapViewContainer/MapSubViewport/OverworldViewer/OverworldTileMapLayer.ToggleViewBiomes(toggled_on,  map.overworld)
