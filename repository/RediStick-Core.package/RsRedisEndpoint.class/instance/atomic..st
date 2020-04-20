transactions
atomic: aBlock 
	self multi.
	aBlock value.
	^ self exec