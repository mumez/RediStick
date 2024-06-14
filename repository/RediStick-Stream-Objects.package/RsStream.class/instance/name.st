accessing
name
	name ifNil: [ name := 'stream-', self identityHash asString ].
	^ name