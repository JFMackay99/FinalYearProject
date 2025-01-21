extends Node

# The map
var map: Array


# Called when the script is instantiated
func _init():
	# Initialise map array
	map = Array()
	for i in Constants.OVERWORLD_MAX_X:
		map.append([])
		for j in Constants.OVERWORLD_MAX_Y:
			map[i].append(0.0)
	

# Generate the overworld map
func GenerateMap() -> Array:
	# Regenerate noise with buffered parameters
	$HeightNoiseHandler.RegenerateNoise()
	
	# Fill the map with height values
	for i in Constants.OVERWORLD_MAX_X:
		for j in Constants.OVERWORLD_MAX_Y:
			map[i][j] = normaliseHeightNoiseValue($HeightNoiseHandler.Get2DNoise(i,j))
			
	return map
	
# Normalise noise value to be between 0 and the maximum height value  
func normaliseHeightNoiseValue(noiseValue: float):
	return Constants.MAX_HEIGHT_LEVELS * (noiseValue+1)/2

# Update noise handlers buffered frequency
func UpdateHeightNoiseFrequency(value: float) -> void:
	$HeightNoiseHandler.NoiseFrequencyBuffer = value

# Update noise handlers buffered seef
func UpdateHeightNoiseSeed(value: float) -> void:
	$HeightNoiseHandler.SeedBuffer = value

# Update noise handlers buffered type
func UpdateHeightNoiseType(index: int) -> void:
	$HeightNoiseHandler.NoiseTypeBuffer = index
	
# Normalise noise value to be between 0 and the maximum height value  
func normaliseBiomeNoiseValue(noiseValue: float):
	return Constants.BIOME_COUNT * (noiseValue+1)/2

# Update noise handlers buffered frequency
func UpdateBiomeNoiseFrequency(value: float) -> void:
	$BiomeNoiseHandler.NoiseFrequencyBuffer = value

# Update noise handlers buffered seef
func UpdateBiomeNoiseSeed(value: float) -> void:
	$BiomeNoiseHandler.SeedBuffer = value

# Update noise handlers buffered type
func UpdateBiomeNoiseType(index: int) -> void:
	$BiomeNoiseHandler.NoiseTypeBuffer = index
