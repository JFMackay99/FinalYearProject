extends Node2D

@export var numberOfDungeons:int = 1
@export var maxHeightLevels = 8

# An array of three dimensional vectors representing the location of dungeon entrances
var DungeonEntrances : Array[Vector3]

# Available views to display to the user
var views : Array[Control]
var ActiveView: Control

# The overall Map
var map: Map

# The Overworld Map
var overworld
#The dungeon layers
var dungeonLayers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Initialise views
	ActiveView = $MapViewContainer/MapSubViewport/OverworldViewer
	views = [$MapViewContainer/MapSubViewport/OverworldViewer, $MapViewContainer/MapSubViewport/DungeonViewer]
	for c: Control in views:
		c.hide()
	ActiveView.set_visible(true)
	#Initialise generators
	$GenerationManager.UpdateMaxHeightLevels(maxHeightLevels)
	
	# Initialise view control
	$ViewControls/LayerSelect.clear()
	$ViewControls/LayerSelect.add_item("Overworld Layer", 0)
	
	for z in maxHeightLevels:
		$ViewControls/LayerSelect.add_item("Dungeon Layer "+ str(z), z+1)
	GenerateMap()

# Generate the overworld
func GenerateOverworld():
	var startOverworldGeneration = Time.get_ticks_msec()
	# Generate Map
	overworld = $OverworldMapGenerator.GenerateMap()
	var endOverworldGeneration = Time.get_ticks_msec()
	var overworldGenerationTime = endOverworldGeneration - startOverworldGeneration
	var startOverworldUpdateTime = Time.get_ticks_msec()
	# Load new overworld to viewer
	$MapViewContainer/MapSubViewport/OverworldViewer/OverworldTileMapLayer.Regenerate(overworld)
	var endOverworldUpdateTime  = Time.get_ticks_msec()
	var overworldUpdateTime = endOverworldUpdateTime-startOverworldUpdateTime
	print("Generate Overworld Map: " + str(overworldGenerationTime)+ "ms") 
	print("Updating Overworld Viewer: " + str(overworldUpdateTime) + "ms")
		
#Generates the Dungeon Layers
func GenerateDungeons():
	# Generate dungeon entrances and load to viewer
	GenerateDungeonEntrances(overworld)
	$MapViewContainer/MapSubViewport/OverworldViewer/DungeonEntrances.AddDungeonEntrances(DungeonEntrances)
	var startGenerateDungeon = Time.get_ticks_msec()
	# Generate the layers of the dungeon and load to viewer
	var layers = $DungeonGenerator.GenerateDungeonLayers(DungeonEntrances)
	var endGenerateDungeon  = Time.get_ticks_msec()
	var generateDungeonTime = endGenerateDungeon-startGenerateDungeon
	dungeonLayers = layers
	var startDungeonViewerUpdate = Time.get_ticks_msec()
	$MapViewContainer/MapSubViewport/DungeonViewer/DungeonTileMapLayer.updateDungeonLayer(layers[0])
	ChangeView($ViewControls/LayerSelect.get_selected_id())
	var endDungeonViewerUpdate = Time.get_ticks_msec()
	var dungeonViewerUpdateTime = endDungeonViewerUpdate - startDungeonViewerUpdate
	# Update the labels showing dungeon entrance coordinates
	UpdateLabels()
	print("Dungeon Generation: " + str(generateDungeonTime) + "ms")
	print("Dungeon Viewer Update: " + str(dungeonViewerUpdateTime) +"ms")
	
# Generates Dungeon Entrances
func GenerateDungeonEntrances(map: Array):
	DungeonEntrances.clear()
	$DungeonGenerator.RegenerateDungeons(map, maxHeightLevels, 64, 64)
	DungeonEntrances = $DungeonGenerator.DungeonEntrances
	
# Update labels showing information about the generated overworld
func UpdateLabels():
	# For now we only need the coordinates of two dungeon entrances
	var entrance = map.entrances[0]
	$ViewControls/E1Coords.text = "(" + str(entrance.x) + "," + str(entrance.y) + ")"
	$ViewControls/E1HeightValue.text = str(entrance.z)
	
	entrance = map.entrances[1]
	$ViewControls/E2Coords.text = "(" + str(entrance.x) + "," + str(entrance.y) + ")"
	$ViewControls/E2HeightValue.text = str(entrance.z)
	
	
# Generate the full overworld. This is also called when the "pressed" signal is emmitted when the 
# regenerate overworld button is pressed.
func GenerateMap() -> void:
	map = $GenerationManager.Generate()
	_UpdateViewers()

func RegenerateDungeon() -> void:
	map = $GenerationManager.RegenerateDungeon()
	_UpdateViewers()
	

func _UpdateViewers():
	$MapViewContainer/MapSubViewport/OverworldViewer/OverworldTileMapLayer.Regenerate(map.overworld.heights)
	$MapViewContainer/MapSubViewport/OverworldViewer/DungeonEntrances.AddDungeonEntrances(map.entrances)
	ChangeView($ViewControls/LayerSelect.get_selected_id())
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
	$MapViewContainer/MapSubViewport/DungeonViewer/DungeonTileMapLayer.updateDungeonLayer(map.dungeon[value-1])
	ActiveView .set_visible(true)
