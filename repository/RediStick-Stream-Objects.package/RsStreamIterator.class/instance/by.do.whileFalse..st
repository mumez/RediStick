actions
by: step do: aBlock whileFalse: endConditionBlock
	| entries strm eachEnt chunkEnts |
	entries := self entriesFrom: self currentId count: step.
	strm := entries readStream.
	eachEnt := nil.
	chunkEnts := OrderedCollection new.
	[
	eachEnt := strm next.
	eachEnt ifNotNil: [ chunkEnts add: eachEnt ].
	eachEnt notNil and: [
		(endConditionBlock cull: chunkEnts cull: eachEnt) not ] ] whileTrue: [
		aBlock value: eachEnt.
		self currentId: eachEnt id ].
	(entries isEmpty or: [entries last id asStreamMessageId > self currentId]) ifTrue: [ ^ self ].
	self by: step do: aBlock whileFalse: endConditionBlock