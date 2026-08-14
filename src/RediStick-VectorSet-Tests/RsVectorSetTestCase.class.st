Class {
	#name : 'RsVectorSetTestCase',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-VectorSet-Tests',
	#package : 'RediStick-VectorSet-Tests'
}

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorA [
	"Small fixture vector standing in for a real embedding (e.g. from
	OllamaClient embed:model:). Kept as a literal so tests don't depend on a
	live embedding server."

	^ #(0.1 0.2 0.3 0.4)
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorB [
	"Close to sampleVectorA, for asserting nearest-neighbor ordering."

	^ #(0.11 0.19 0.31 0.41)
]

{ #category : 'fixtures' }
RsVectorSetTestCase class >> sampleVectorC [
	"Far from sampleVectorA/sampleVectorB, for asserting nearest-neighbor ordering."

	^ #(-0.4 -0.3 -0.2 -0.1)
]
