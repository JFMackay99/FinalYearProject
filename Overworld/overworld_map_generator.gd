extends Node

# The heights
var heights: Array
var biomes: Array

# Called when the script is instantiated
func _init():
	# Initialise map array
	heights = Array()
	for i in Constants.OVERWORLD_MAX_X:
		heights.append([])
		for j in Constants.OVERWORLD_MAX_Y:
			heights[i].append(0.0)
	
	
	biomes = Array()
	for i in Constants.OVERWORLD_MAX_X:
		biomes.append([])
		for j in Constants.OVERWORLD_MAX_Y:
			biomes[i].append(0)

# Generate the overworld map
func GenerateMap(overworld: OverworldMap):
	# Regenerate noise with buffered parameters
	$HeightNoiseHandler.RegenerateNoise()
	
	# Generate height values
	for i in Constants.OVERWORLD_MAX_X:
		for j in Constants.OVERWORLD_MAX_Y:
			heights[i][j] = NormaliseHeightNoiseValue($HeightNoiseHandler.Get2DNoise(i,j))
	
	# Generate Biomes
	for i in Constants.OVERWORLD_MAX_X:
		for j in Constants.OVERWORLD_MAX_Y:
			biomes[i][j] = NormaliseBiomeNoiseValue($HeightNoiseHandler.Get2DNoise(i,j))
			
	overworld.UpdateHeights(heights)
	overworld.UpdateBiomes(biomes)

	
# Normalise noise value to be between 0 and the maximum height value  
func NormaliseHeightNoiseValue(noiseValue: float):
	return Constants.MAX_HEIGHT_LEVELS * (noiseValue+1)/2

# Normalise Noise Value for Biomes
func NormaliseBiomeNoiseValue(noiseValue: float):
	var nf = (noiseValue+1)/2 # Between 0 and 1
	nf = Constants.BIOME_COUNT * nf # Between 0 and n
	nf = ceil(nf) # int 0-n 
	return nf if nf != 0 else 1 # 1-n


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
