constants
max
	^ max ifNil: [ max := self reserved: '+' ]