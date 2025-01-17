extends Node

# The map
var map: Array

# Map size parameters
@export var height = 64
@export var width =64
@export var maxHeightLevels = 8

# Called when the script is instantiated
func _init():
	# Initialise map array
	map = Array()
	for i in height:
		map.append([])
		for j in width:
			map[i].append(0.0)
	

# Generate the overworld map
func GenerateMap() -> Array:
	# Regenerate noise with buffered parameters
	$HeightNoiseHandler.RegenerateNoise()
	
	# Fill the map with height values
	for i in height:
		for j in height:
			map[i][j] = normaliseNoiseValue($HeightNoiseHandler.Get2DNoise(i,j))
			
	return map
	
# Normalise noise value to be between 0 and the maximum height value  
func normaliseNoiseValue(noiseValue: float):
	return maxHeightLevels * (noiseValue+1)/2


# Update noise handlers buffered frequency
func UpdateHeightNoiseFrequency(value: float) -> void:
	$HeightNoiseHandler.NoiseFrequencyBuffer = value

# Update noise handlers buffered seef
func UpdateHeightNoiseSeed(value: float) -> void:
	$HeightNoiseHandler.SeedBuffer = value

# Update noise handlers buffered type
func UpdateHeightNoiseType(index: int) -> void:
	$HeightNoiseHandler.NoiseTypeBuffer = index
