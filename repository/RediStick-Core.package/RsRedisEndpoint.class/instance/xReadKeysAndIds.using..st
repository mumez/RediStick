commands-stream
xReadKeysAndIds: keysAndIds using: optionsBlock
	| opts keys ids |
	opts := RsStreamReadOptions new.
	optionsBlock value: opts.
	keys := keysAndIds collect: [ :each | each key ].
	ids := keysAndIds collect: [ :each | each value ].
	^ self xReadOptions: opts keys: keys ids: ids