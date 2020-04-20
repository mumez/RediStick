transactions
atomic: aBlock watch: keys 
	self watch: keys.
	self multi.
	aBlock value.
	^ self exec