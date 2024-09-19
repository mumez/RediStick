constants
neverDelivered
	^ neverDelivered ifNil: [ neverDelivered := self reserved: '>' ]