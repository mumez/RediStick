constants
all
	^ all ifNil: [ all := self reserved: '0' ]