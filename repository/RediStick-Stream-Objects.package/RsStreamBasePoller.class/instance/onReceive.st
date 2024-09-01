callback
onReceive

	^ onReceive ifNil: [ onReceive := [ :received |  ] ]