accessing
name

	^ name ifNil: [ name := self generateName ]