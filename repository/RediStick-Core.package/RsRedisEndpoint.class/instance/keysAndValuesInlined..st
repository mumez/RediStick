private

keysAndValuesInlined: aDictionary
	"I'm transforming a dictionary into a flat dictionary"

	"RsRedisEndpoint new keysValueInline: (Dictionary with: ('keyA' -> 'valueB') with: ('keyB' -> 'valueB'))>>> #('keyA' 'valueB' 'keyB' 'valueB')"

	| writeStream |
	writeStream := WriteStream with: #().
	aDictionary
		keysAndValuesDo: [ :key :value | 
			writeStream
				nextPut: key;
				nextPut: value ].
	^ writeStream contents
