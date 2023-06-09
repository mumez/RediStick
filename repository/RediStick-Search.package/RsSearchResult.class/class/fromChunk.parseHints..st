instance creation
fromChunk: chunkArray parseHints: parseHints

	| inst id hints readStream |
	inst := self new.
	id := chunkArray at: 1.
	inst id: id.
	chunkArray size = 1 ifTrue: [ ^ inst ].
	hints := parseHints copy.
	readStream := (chunkArray copyFrom: 2 to: chunkArray size) readStream.
	[ readStream atEnd ] whileFalse: [
		| nextValue |
		nextValue := readStream next.
		inst loadValueFromChunk: nextValue hints: hints ].

	^ inst