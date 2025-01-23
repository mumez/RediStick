commands-lists
lMoveFrom: source to: destination
	^ self
		  lMoveFrom: source
		  removing: 'RIGHT'
		  to: destination
		  adding: 'LEFT'