private
keysAndValuesInlined: aDictionary
	| writeStream |
	writeStream := WriteStream with: #().
	aDictionary
		keysAndValuesDo: [ :key :value | 
			writeStream
				nextPut: key;
				nextPut: value ].
	^ writeStream contents