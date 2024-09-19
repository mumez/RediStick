*RediStick-Stream
xReadKeysAndIds: keysAndIds using: optionsBlock
	| opts keys ids |
	opts := RsStreamReadOptions new.
	optionsBlock value: opts.
	keys := keysAndIds collect: [ :each | each key asString ].
	ids := keysAndIds collect: [ :each | each value asString ].
	^ self xReadOptions: opts keys: keys ids: ids