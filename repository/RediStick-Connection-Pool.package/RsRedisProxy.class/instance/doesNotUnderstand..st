reflective operations
doesNotUnderstand: aMessage 
	| pool |
	pool := self connectionPool.
	pool ifNil: [ ^super doesNotUnderstand: aMessage  ].
	
	^ pool connectionDo: [:redis | redis perform: aMessage selector withEnoughArguments: aMessage arguments ] at: self connectionKey