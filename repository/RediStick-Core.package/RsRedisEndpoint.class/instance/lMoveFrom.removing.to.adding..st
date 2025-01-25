commands-lists
lMoveFrom: source removing: srcFromRightOrLeft to: destination adding: destToRightOrLeft
	| srcRightOrLeft destRightOrLeft |
	srcRightOrLeft := srcFromRightOrLeft
		                  ifNil: [ 'RIGHT' ]
		                  ifNotNil: [ srcFromRightOrLeft ]. "RIGHT or LEFT"
	destRightOrLeft := destToRightOrLeft
		                   ifNil: [ 'LEFT' ]
		                   ifNotNil: [ destToRightOrLeft ]. "RIGHT or LEFT"
	^ self unifiedCommand: {
			  'LMOVE'.
			  source.
			  destination.
			  srcRightOrLeft.
			  destRightOrLeft }