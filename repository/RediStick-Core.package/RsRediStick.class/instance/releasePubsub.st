releasing
releasePubsub
	self endpoint ifNotNil: [ :ep | ep isPubsub ifTrue: [ ep releasePubsub ] ]