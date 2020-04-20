startup-shutdown
onImageQuit
	self endpoint ifNotNil: [ :ep | ep isPubsub ifTrue: [ ep releasePubsub ] ]