accessing
autoCreateStream

	^ autoCreateStream ifNil: [ autoCreateStream := false ]