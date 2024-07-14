actions
by: step do: aBlock
	^ self
		  by: step
		  do: aBlock
		  whileFalse: [ :entries :id | entries isEmpty ]