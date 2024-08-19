accessing
logger

	^ logger ifNil: [ logger := self defaultLogger ]