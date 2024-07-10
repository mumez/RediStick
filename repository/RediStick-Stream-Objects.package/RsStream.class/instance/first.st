reading
first
	| elems |
	elems := self first: 1.
	^ elems ifNotEmpty: [ elems first ] ifEmpty: [  ]