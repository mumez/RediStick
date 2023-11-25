*RediStick-Stream
xGroupReadKeysAndIds: keysAndIds group: group consumer: consumer using: optionsBlock
	| opts keys ids |
	opts := RsStreamGroupReadOptions new.
	optionsBlock value: opts.
	keys := keysAndIds collect: [ :each | each key ].
	ids := keysAndIds collect: [ :each | each value ].
	^ self xGroupReadOptions: opts group: group consumer: consumer keys: keys ids: ids