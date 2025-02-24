extends GutTest

var generator: OverworldMapGenerator

func before_all():
	generator = OverworldMapGenerator.new()

var normaliseBiomeNoiseValueParams = [
	[0,2],
	[-1,1],
	[1,4]
]
func test_NormaliseBiomeNoiseValue(params=use_parameters(normaliseBiomeNoiseValueParams)):
	var biomeCount = 4
	var noiseValue = params[0]
	var expected = params[1]
	 
	var actual = generator.NormaliseBiomeNoiseValue(noiseValue, biomeCount)
	
	assert_eq(actual, expected)


var normaliseHeightNoiseValueParams = [
	[0,2],
	[-1,0],
	[1,4]
]
func test_NormaliseHeightNoiseValue(params=use_parameters(normaliseHeightNoiseValueParams)):
	var maxHeight = 4
	var noiseValue = params[0]
	var expected = params[1]
	 
	var actual = generator.NormaliseHeightNoiseValue(noiseValue, maxHeight)
	
	assert_eq(actual, expected)
